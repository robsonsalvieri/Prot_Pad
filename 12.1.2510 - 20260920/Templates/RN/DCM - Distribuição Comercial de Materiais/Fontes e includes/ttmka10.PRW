#INCLUDE "ttmka10.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "TOPCONN.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTTMKA10   |Autor  ณEWERTON C TOMAZ     บ Data ณ  18/07/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRotina para criacao e manutencao da tabela de orcamentos    บฑฑ
ฑฑบ          ณpor centro de custos                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Template Function TTMKA10(_cOper)
Local _nVez
Local _nVezCab
Local _nX

CHKTEMPLATE("DCM")  

Static _lPrim
If _lPrim== Nil
	_lPrim:=.t.
EndIf   

Dbselectarea("LHA")
Private cString:=alias(),;
cCadastro:=cTitulo:=STR0001,; //'Orcamento por Centro de Custo'
_cTudoOk:="TudoOk",_cLinhaOk:="LinhaOk",;
_cVisual:="Visualizar",_cIncluir:="Incluir",_cAlterar:="Alterar",_cExcluir:="Excluir",;
_cReFresh:="Refresh",_cGeraOrc:="GeraOrc",_cPesquisa:="Pesquisa",inclui:=altera:=_lAtend:=.f.
cArq := ''
aFields := {}
_nSomaTo := 0

Do Case
	Case _cOper== Nil // Chamada do menu
		
		Private _cCampos  := "LHA_NUMREQ,LHA_CLIENT,LHA_LOJA,LHA_EMISSA,LHA_NUMORC"
		
		aCamposMB := {}
		DbSelectArea('SX3')
		DbSetOrder(1)
		DbSeek('LHA')
		While !Eof() .And. X3_ARQUIVO = 'LHA'
			If ALLTRIM(X3_CAMPO) $ _cCampos
				AADD(aCamposMB,{Alltrim(X3_TITULO),Alltrim(X3_CAMPO),Alltrim(X3_TIPO),X3_TAMANHO,X3_DECIMAL,Alltrim(X3_PICTURE)})
			EndIf
			DbSkip()
		End  
		DbSeek('SA1')
		While !Eof() .And. X3_ARQUIVO = 'SA1'
			If ALLTRIM(X3_CAMPO)+' ' $ 'A1_NOME '
				AADD(aCamposMB,{Alltrim(X3_TITULO),Alltrim(X3_CAMPO),Alltrim(X3_TIPO),X3_TAMANHO,X3_DECIMAL,Alltrim(X3_PICTURE)})
				Exit
			EndIf
			DbSkip()
		End  
		
		Cria_TLHA()
		
		DbSelectArea('TLHA')
		
		Processa({|| Monta_TLHA() } ,STR0002) //"Selecionando Informacoes..."
		
		cDelFunc := ".T."
		
		aRotina := MenuDef()
		
		aCores := {{'!Empty(TLHA->LHA_NUMORC)', 'BR_VERMELHO'},;
		{'Empty(TLHA->LHA_NUMORC)', 'BR_VERDE'}}
		
		mBrowse( 6,1,22,75,"TLHA",aCamposMB,,,,, aCores)
		
		DbSelectArea('TLHA')
		DbCloseArea()
		Erase(cArq)
		
	Case _cOper$_cVisual+_cIncluir+_cAlterar+_cExcluir
		
		SetKey(120 , { || T_TTMKC01(aCols[n,3]) }) // F9
		SetKey(116 , { || M->UA_CLIENTE := _cCliente,T_TMKPENDb()})
		
		altera:=(_cOper==_cAlterar)
		Inclui:=(_cOper==_cIncluir)
		
		If _cOper$_cVisual+_cExcluir
			nOpcx:=5
		Else
			nOpcx:=3
		EndIf
		
		SX3->(DbSetOrder(1))
		SX3->(DbSeek(cString,.f.))
		nUsado :=0
		aHeader:={}
		While SX3->(!Eof().And.x3_arquivo==cString)
			
			If SX3->(X3USO(x3_usado).AND.cNivel>=x3_nivel.AND.X3_BROWSE='S')
				nUsado++
				
				_cValid:=sx3->(alltrim(x3_valid)+iIf(empty(x3_valid).or.empty(x3_vlduser),"",".and.")+;
				alltrim(x3_vlduser))
				
				SX3->(AAdd(aHeader,{Alltrim(x3_titulo),X3_campo,X3_picture,;
				X3_tamanho,X3_decimal,_cValid,;
				X3_usado,X3_tipo,X3_arquivo,X3_context}))
				
			EndIf
			
			SX3->(DbSkip())
		End  
		aCols:=Array(1,nUsado+1)
		sx3->(DbSeek(cString,.f.))
		nUsado:= 0
		While SX3->(!Eof().And.x3_arquivo==cString)
			If SX3->(X3USO(x3_usado).AND.cNivel>=X3_nivel.AND.X3_BROWSE='S')
				nUsado++
				If nOpcx == 3
					If SX3->X3_tipo == "C"
						aCols[1][nUsado] := Space(SX3->X3_tamanho)
					ElseIf SX3->X3_tipo == "N"
						aCols[1][nUsado] := 0
					ElseIf sx3->x3_tipo == "D"
						aCols[1][nUsado] := dDataBase
					ElseIf SX3->x3_tipo == "M"
						aCols[1][nUsado] := ""
					Else
						aCols[1][nUsado] := .F.
					EndIf
				EndIf
			EndIf
			sx3->(DbSkip())
		End  
		aCols[1][nUsado+1] := .F.
		// Variaveis do Cabecalho do Modelo 2
		_cNumReq :=criavar("LHA_NUMREQ")
		_cCliente:=criavar("LHA_CLIENT")
		_cLoja   :=criavar("LHA_LOJA")
		_cNomeCli:=criavar("LHA_NOME")
		_cVend   :=criavar("LHA_VEND")
		_cNomeVen:=criavar("LHA_NOMEVE")
		_dDtcad  :=criavar("LHA_EMISSA")
		_cNumOrc :=criavar("LHA_NUMORC")
		
		nLinGetD:=0
		aC:={}
		_vCamposCab:={{"LHA_NUMREQ"  ,"_cNumReq",{015,003}},;
		              {"LHA_EMISSA" ,"_dDtCad"  ,{015,065}},;
		              {"LHA_NUMORC" ,"_cNumOrc" ,{015,135}},;
		              {"LHA_VEND"   ,"_cVend"   ,{015,215}},;
		              {"LHA_CLIENT" ,"_cCliente",{030,003}},;
              		{"LHA_LOJA"   ,"_cLoja"   ,{030,065}},;
		              {"LHA_NOME"   ,"_cNomeCli",{030,135}}}
		
		For _nVez:=1 To Len(_vCamposCab)
			_cCampo := Upper(_vCamposCab[_nVez][1])
			_cVar   :=_vCamposCab[_nVez][2]
			_vLinCol:=_vCamposCab[_nVez][3]
			sx3->(DbSetOrder(2))
			sx3->(DbSeek(padr(_cCampo,Len(x3_campo)),.f.))
			_cTitulo :=alltrim(sx3->x3_titulo)
			
			_cF3     :=sx3->x3_f3
			_lEdita  :=(sx3->x3_visual<>"V")
			
			If _cCampo$"LHA_NUMREQ/LHA_CLIENT/LHA_LOJA/LHA_VEND/LHA_EMISSA/LHA_NUMORC".and._lEdita
				_lEdita:=inclui
			EndIf
			
			_cPicture:=sx3->x3_picture
			_cValid:=sx3->(alltrim(x3_valid)+If(Empty(x3_valid).or.Empty(x3_vlduser),"",".and.")+;
			alltrim(x3_vlduser))
			
			If alltrim(_cCampo)=="LHA_CLIENT"
				_cValid:="existcpo('SA1')"
			ElseIf alltrim(_cCampo)=="LHA_VEND"
				_cValid:="existcpo('SA3')"
			ElseIf alltrim(_cCampo)=="LHA_NOME"
				_lEdita := .F.
			EndIf
			_cValid+=If(Empty(_cValid),"",".and.")+"T_TTMKA10(_cRefresh)"
			
			AAdd(aC,{_cVar,_vLinCol,_cTitulo,_cPicture,_cValid,_cF3,_lEdita})
		Next
		
		If _cOper$_cVisual+_cAlterar+_cExcluir
			LHA->(DbSelectArea(1))
			LHA->(DbSeek(xFilial('LHA')+TLHA->LHA_NUMREQ))
			_cNomeCli := Posicione('SA1',1,xFilial('SA1')+LHA->LHA_CLIENT+LHA->LHA_LOJA,'A1_NOME')
		EndIf
		
		_cVend := Posicione('SA3',2,xFilial('SA3')+Upper(cUserName),'A3_COD')
		
		aR:={}
		_vCamposRod:={}
		
		sx3->(DbSetOrder(1))
		aCGD:={80,5,190,395}
		cLinhaOk:="T_TTMKA10(_cLinhaOk)"
		cTudoOk :="T_TTMKA10(_cTudoOk)"
		
		If _cOper$_cVisual+_cAlterar+_cExcluir
			For _nVezCab:=1 To Len(_vCamposCab)
				If !(_vCamposCab[_nVezCab][1] $ 'LHA_NOME')
					_cComando:=_vCamposCab[_nVezCab][2]+":=LHA->"+_vCamposCab[_nVezCab][1]
					_x:=&_cComando
				EndIf
			Next
			_nOrdLHA:=LHA->(indexord())
			_nRecLHA:=LHA->(Recno())
			LHA->(DbSetOrder(1))
			LHA->(DbSeek(xfilial("LHA")+_cNumReq))
			_lPrim:=.t.
			While LHA->(! Eof()) .AND. LHA->LHA_FILIAL == xfilial("LHA") .AND. LHA->LHA_NUMREQ == _cNumReq
				If _lPrim
					_lPrim:=.f.
				Else
					aadd(aCols,)
				EndIf
				_cComando:='Acols[len(aCols)]:=LHA->({'
				For _nVez:=1 To Len(aHeader)
					_cComando+=aHeader[_nVez,2]+','
				Next
				_cComando+=+'.f.})'
				_x:=&_cComando
				LHA->(DbSkip(1))
			End  
			LHA->(DbGoto(_nRecLHA))
			LHA->(DbSetOrder(_nOrdLHA))
		EndIf
		
		lRetMod2:=Modelo2(cTitulo,aC,aR,aCGD,nOpcx,cLinhaOk,cTudoOk,,,,999,{120,0,520,797})
		
		If lRetMod2
			_nOrdLHA:=LHA->(indexord())
			LHA->(DbSetOrder(1))
			Do Case
				Case _cOper=="Incluir"
					_nItem:=1
					For _nVez:=1 To Len(aCols)
						If !LHA->(DbSeek(xfilial("LHA")+_cNumReq+_cCliente+_cLoja+aCols[_nVez,1])) .And. !aCols[_nVez,nUsado+1]
							RecLock('LHA',.T.)
							LHA->LHA_FILIAL  := xFilial('LHA')
							LHA->LHA_NUMREQ  := _cNumReq
							LHA->LHA_CLIENT := _cCliente
							LHA->LHA_LOJA    := _cLoja
							LHA->LHA_VEND    := _cVend
							LHA->LHA_EMISSA := _dDtCad
							LHA->LHA_NUMORC  := _cNumOrc
							_fReplLHA(_nVez)
							MsUnlock()
						EndIf
					Next
					ConfirmSx8()
				Case _cOper=="Alterar"
					// Primeiro verIfica eventuais exclusoes de itens
					For _nVez:=1 To Len(aCols)
						If LHA->(DbSeek(xfilial("LHA")+_cNumReq+_cCliente+_cLoja+aCols[_nVez,1]))
							_lNovo := .F.
						Else
							_lNovo := .T.
						EndIf
						If !aCols[_nVez,nUsado+1]
							RecLock('LHA',_lNovo)
							LHA->LHA_FILIAL  := xFilial('LHA')
							LHA->LHA_NUMREQ  := _cNumReq
							LHA->LHA_CLIENT  := _cCliente
							LHA->LHA_LOJA    := _cLoja
							LHA->LHA_VEND    := _cVend
							LHA->LHA_EMISSA  := _dDtCad
							LHA->LHA_NUMORC  := _cNumOrc
							_fReplLHA(_nVez)
							MsUnlock()
						Else
							RecLock('LHA',.F.)
							DbDelete()
							MsUnlock()
						EndIf
					Next
				Case _cOper=="Excluir" .and. msgyesno(STR0009+STR0010) //"Todos os itens da tabela" ## " serao excluidos, confirma ?"
					LHA->(DbSetorder(1))
					LHA->(DbSeek(xfilial("LHA")+_cNumReq+_cCliente+_cLoja))
					While LHA->(! Eof()) .AND. LHA->LHA_FILIAL == xfilial("LHA") .AND. LHA->LHA_NUMREQ == _cNumReq
						If LHA->(reclock(alias(),.f.))
							LHA->(dbdelete())
							LHA->(msunlock())
						EndIf
						LHA->(DbSkip(1))
					End  
			EndCase
			LHA->(DbSetOrder(_nOrdLHA))
		EndIf
		If (_cOper$_cIncluir+_cAlterar+_cExcluir .And. lRetMod2) .Or. (_cOper$_cIncluir .And. !lRetMod2)
			T_TTMKA10(STR0011) //'Refaz'
		EndIf
		SetKey(120 , )
		SetKey(116 , )
		Return
	Case _cOper==_cLinhaOk
		_lLinhaOk:=.T.
		
		_nSomaTo := 0
		_cMen  := ''
		_nPosPreco  := AsCan(aHeader,{|x|Alltrim(Upper(x[2]))=='LHA_VALOR'})
		_nPosTotal  := AsCan(aHeader,{|x|Alltrim(Upper(x[2]))=='LHA_TOTAL'})
		For _nVez:=1 To Len(aCols)
			If !aCols[_nVez,nUsado+1]
				_nSomaTo += aCols[_nVez,_nPosTotal]
			EndIf
		Next
		
		If !aCols[n,nUsado+1]
			If Empty(aCols[n,3])
				_cMen += STR0012+Chr(13) //"Informe o Codigo do Produto !"
			ElseIf Empty(aCols[n,2])
				_cMen += STR0013+Chr(13) //"Informe o Codigo do Requisitante !"
			ElseIf Empty(aCols[n,_nPosPreco])
				_cMen += STR0014+Chr(13) //"Informe o Preco Unitario !"
			EndIf
		EndIf
		
		If !Empty(_cMen)
			MsgStop(_cMen)
			_lLinhaOk := .F.
		EndIf
		
		@ 193,330 Say STR0015 SIZE 60,40 //'Total'
		@ 192,350 Get _nSomaTo picture '@ER 9999,999.99' SIZE 40,40 when .f.
		
		Return _lLinhaOk
		
	Case _cOper==_cTudoOk
		_lTudoOk:=.t.
		
		Return _lTudoOk
	Case _cOper==_cReFresh
		_cField:=readvar()
		
		_nPosProd   := AsCan(aHeader,{|x|Alltrim(Upper(x[2]))=='LHA_PRODUT'})
		_nPosDescri := AsCan(aHeader,{|x|Alltrim(Upper(x[2]))=='LHA_DESCRI'})
		_nPosUM     := AsCan(aHeader,{|x|Alltrim(Upper(x[2]))=='LHA_UM'})
		_nPosQuant  := AsCan(aHeader,{|x|Alltrim(Upper(x[2]))=='LHA_QUANT'})
		_nPosPreco  := AsCan(aHeader,{|x|Alltrim(Upper(x[2]))=='LHA_VALOR'})
		_nPosTotal  := AsCan(aHeader,{|x|Alltrim(Upper(x[2]))=='LHA_TOTAL'})
		
		Do Case
			Case Lower(alltrim(_cField))=="_ccliente"
				_cNomeCli := Posicione('SA1',1,xFilial('SA1')+_cCliente+_cLoja,'A1_NOME')
				_cLoja    := SA1->A1_LOJA
			Case Lower(alltrim(_cField))=="m->LHA_PRODUT"
				Posicione('SB1',1,xFilial('SB1')+m->LHA_PRODUT,'')
				aCols[n,_nPosDescri] := SB1->B1_DESC
				aCols[n,_nPosUM]     := SB1->B1_UM
				aCols[n,_nPosQuant]  := 1
				If T_BuscaValCon(_cCliente,m->LHA_PRODUT)
					aCols[n,_nPosPreco]  := LH5->LH5_VALOR
				Else
					aCols[n,_nPosPreco]  := Posicione('SB0',1,xFilial('SB0')+m->LHA_PRODUT,'B0_PRV1')
				EndIf
				aCols[n,_nPosTotal]  := aCols[n,_nPosPreco] * aCols[n,_nPosQuant]
			Case Lower(alltrim(_cField))=="m->LHA_quant"
				aCols[n,_nPosTotal]  := aCols[n,_nPosPreco] * m->LHA_quant
			Case Lower(alltrim(_cField))=="m->LHA_valor"
				aCols[n,_nPosTotal]  := m->LHA_valor * aCols[n,_nPosQuant]
		EndCase
		Return (.T.)
	Case "pegalinha"$lower(alltrim(_cOper))
		Return(StrZero(val(aCols[Len(aCols)-1,1])+1,4,0))
	Case "refaz"$lower(alltrim(_cOper))
		DbSelectArea('TLHA')
		DbCloseArea()
		Erase(cArq)
		Cria_TLHA()
		DbSelectArea('TLHA')
		Processa({|| Monta_TLHA() } ,STR0002) //"Selecionando Informacoes..."
	Case "pesquisa"$lower(alltrim(_cOper))
		T_PesqLHA()
		Return(.T.)
	Case "geraorc"$lower(alltrim(_cOper))
		DbSelectArea('LHA')
		DbSetOrder(1)
		Dbseek(xfilial("LHA")+TLHA->LHA_NUMREQ)
		Posicione('SA1',1,xFilial('SA1')+LHA->LHA_CLIENT+LHA->LHA_LOJA,'')

		If !Empty(LHA->LHA_NUMORC)
		   _cNumOrc := LHA->LHA_NUMORC
		   
		   If MsgYesNo(STR0016 + _cNumOrc + STR0017) //"ATENCAO: Ja existe orcamento gerado por esta rotina - Orcamento N. "###" ! - Deseja Exclui-lo ?"
				DbSelectArea('SUA')
				DbSetOrder(1)
				If DbSeek(xfilial("SUA")+_cNumOrc)
				
   				   If !Empty(SUA->UA_NUMSC5)
				      MsgStop(STR0018 + SUA->UA_NUMSC5 + STR0019) //"ATENCAO: Este Orcamento Ja Possui Pedido - "###"  Impossivel Exporta-lo Novamente !"
					  Return
				   EndIf
				
  				   DbSelectArea('SUB')
				   DbSetOrder(1)
				   DbSeek(xfilial("SUB")+_cNumOrc)
				   While SUB->(! Eof()) .AND. SUB->UB_FILIAL == xfilial("SUB") .AND. SUB->UB_NUM == _cNumOrc
				      RecLock("SUB",.f.)
				      DbDelete()
				      msUnlock()
				      DbSkip(1) 
				   End
				   
				   DbSelectArea('SUA')
				   RecLock("SUA",.f.)
				   DbDelete()
				   msUnlock()                                                                                                         
				   
				   MsgBox(STR0020,STR0021,'INFO') //"ORCAMENTO APAGADO COM SUCESSO !"###'Orcamento'
				EndIf
		   EndIf
		EndIf		

		If !MsgYesNo(STR0022) //"Confirma a geracao do Novo Orcamento ?"
			Return
		EndIf
		
		_lPri := .F.
		_aItens := {}
		_aPedOk := {}
		Begin Transaction
		While LHA->(! Eof()) .AND. LHA->LHA_FILIAL == xfilial("LHA") .AND. LHA->LHA_NUMREQ == TLHA->LHA_NUMREQ
			
			If !_lPri
				_cTes := ''
				DbSelectArea('SUA')
				RecLock('SUA',.T.)
				SUA->UA_FILIAL  := xFilial('SUA')
				SUA->UA_NUM     := TkNumero('SUA','UA_NUM')
				SUA->UA_OPERADO := Posicione('SU7',3,xFilial('SU7')+Alltrim(SA1->A1_NOMVEND),'U7_COD')
				SUA->UA_CLIENTE := SA1->A1_COD
				SUA->UA_LOJA    := SA1->A1_LOJA
				SUA->UA_DESCCLI := SA1->A1_NOME
				SUA->UA_TMK     := '2'
				SUA->UA_OPER    := '2'
				SUA->UA_VEND    := SA1->A1_VEND
				SUA->UA_FATINT  := 'S'
				SUA->UA_AGLUTIN := SA1->A1_AGLUTIN
				SUA->UA_EMISSAO := dDatabase
				SUA->UA_CONDPG  := If(!Empty(SA1->A1_COND),SA1->A1_COND,SuperGetMv('MV_CONDPAD'))
				SUA->UA_CONDAF  := If(!Empty(SA1->A1_COND),SA1->A1_COND,SuperGetMv('MV_CONDPAD'))				
				SUA->UA_STATUS  := 'SUP'
				SUA->UA_ENDCOB  := SA1->A1_ENDCOB
				SUA->UA_BAIRROC := SA1->A1_BAIRROC
				SUA->UA_CEPC    := SA1->A1_CEPC
				SUA->UA_MUNC    := SA1->A1_MUNC
				SUA->UA_ESTC    := SA1->A1_ESTC
				SUA->UA_ENDENT  := SA1->A1_ENDENT
				SUA->UA_BAIRROE := SA1->A1_BAIRROE
				SUA->UA_CEPE    := SA1->A1_CEPE
				SUA->UA_MUNE    := SA1->A1_MUNE
				SUA->UA_ESTE    := SA1->A1_ESTE
				SUA->UA_TRANSP  := SA1->A1_TRANSP
				SUA->UA_TPFRETE := SA1->A1_TPFRET
				SUA->UA_PROSPEC := .F.
				MsUnlock()
				_lPri := .T.
				AaDd(_aPedOk,SUA->UA_NUM)
			EndIf
			_nDireita := 1
			_cTexto := '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ'
			
			Posicione('SB1',1,xFilial('SB1')+LHA->LHA_PRODUT,'B1_DESC')
			_cTes          := If(!Empty(_cTes),_cTes,If(!Empty(SB1->B1_TS),SB1->B1_TS,'501'))
			Posicione('SB0',1,xFilial('SB0')+LHA->LHA_PRODUT,'B0_PRV1')
			Posicione('LH4',2,xFilial('LH4')+SA1->A1_COD+SA1->A1_LOJA,'LH4_COMISS')
			Posicione('LH7',1,xFilial('LH7')+LHA->LHA_PRODUT,'LH7_PRC')			
			_nPerCom := LH4->LH4_COMISS
			
			_nPosProd := If(Len(_aItens)>0,Ascan(_aItens,{|x|Alltrim(x[4])=Alltrim(LHA->LHA_PRODUT)}),0)
			If _nPosProd = 0
				
				AaDd(_aItens,{xFilial('SUB'),;
				              LHA->LHA_ITEM,;
				              SUA->UA_NUM,;
				              LHA->LHA_PRODUT,;
				              SB1->B1_DESC,;
				              LHA->LHA_QUANT,;
				              LHA->LHA_VALOR,;
				              LHA->LHA_TOTAL,;
				              SB0->B0_PRV1,;
				              SB1->B1_UM,;
				              dDatabase+2,;
				              _cTes,;
				              If(SA1->A1_EST = SuperGetMv('MV_ESTADO'),Posicione('SF4',1,xFilial('SF4')+_cTes,'F4_CF'),'6'+SubStr(Posicione('SF4',1,xFilial('SF4')+_cTes,'F4_CF'),2,3)),;
				              '9',;
				              '01',;
				              (LHA->LHA_TOTAL*SB1->B1_PICM)/100,;
				              (LHA->LHA_TOTAL*SB1->B1_IPI)/100,;
				              LHA->LHA_TOTAL,;
				              LHA->LHA_VALOR,;
				              _nPerCom,;
				              If(!Empty(_nPerCom),LHA->LHA_TOTAL*_nPerCom,0),;
				              LH7->LH7_PYPRCL,;
				              LHA->LHA_CODCLI})
			Else
				_aItens[_nPosProd,6] += LHA->LHA_QUANT
				_aItens[_nPosProd,8] := (_aItens[_nPosProd,7]*_aItens[_nPosProd,6])
				_aItens[_nPosProd,16]:= (_aItens[_nPosProd,8]*SB1->B1_PICM)/100
				_aItens[_nPosProd,17]:= (_aItens[_nPosProd,8]*SB1->B1_IPI)/100
				_aItens[_nPosProd,18]:= _aItens[_nPosProd,8]
				_aItens[_nPosProd,21]:= If(!Empty(_nPerCom),((_aItens[_nPosProd,8]*_nPerCom)/100),0)
			EndIf
			DbSelectArea('LHA')
			RecLock('LHA',.F.)
			LHA->LHA_NUMORC := SUA->UA_NUM
			MsUnLock()
			DbSkip()
		EndDo  
		
		For _nX := 1 To Len(_aItens)
			RecLock('SUB',.T.)
			If _nDireita > 36
				_nDireita := 1
			EndIf
			If _nX < 100
				_cItem := StrZero(_nX,2)
			Else
				If _nX <= 136
					_cItem := 'A' + SubStr( _cTexto , _nDireita , 1)
					_nDireita++
				ElseIf _nX <= 172
					_cItem := 'B' + SubStr( _cTexto , _nDireita , 1)
					_nDireita++
				ElseIf _nX <= 208
					_cItem := 'C' + SubStr( _cTexto , _nDireita , 1)
					_nDireita++
				ElseIf _nX <= 244
					_cItem := 'D' + SubStr( _cTexto , _nDireita , 1)
					_nDireita++
				ElseIf _nX <= 280
					_cItem := 'E' + SubStr( _cTexto , _nDireita , 1)
					_nDireita++
				ElseIf _nX <= 316
					_cItem := 'F' + SubStr( _cTexto , _nDireita , 1)
					_nDireita++
				ElseIf _nX <= 352
					_cItem := 'G' + SubStr( _cTexto , _nDireita , 1)
					_nDireita++
				ElseIf _nX <= 388
					_cItem := 'H' + SubStr( _cTexto , _nDireita , 1)
					_nDireita++
				ElseIf _nX <= 424
					_cItem := 'I' + SubStr( _cTexto , _nDireita , 1)
					_nDireita++
				ElseIf _nX <= 460
					_cItem := 'J' + SubStr( _cTexto , _nDireita , 1)
					_nDireita++
				ElseIf _nX <= 496
					_cItem := 'K' + SubStr( _cTexto , _nDireita , 1)
					_nDireita++
				ElseIf _nX <= 532
					_cItem := 'L' + SubStr( _cTexto , _nDireita , 1)
					_nDireita++
				ElseIf _nX <= 568
					_cItem := 'M' + SubStr( _cTexto , _nDireita , 1)
					_nDireita++
				ElseIf _nX <= 604
					_cItem := 'N' + SubStr( _cTexto , _nDireita , 1)
					_nDireita++
				ElseIf _nX <= 640
					_cItem := 'O' + SubStr( _cTexto , _nDireita , 1)
					_nDireita++
				ElseIf _nX <= 676
					_cItem := 'P' + SubStr( _cTexto , _nDireita , 1)
					_nDireita++
				ElseIf _nX <= 712
					_cItem := 'Q' + SubStr( _cTexto , _nDireita , 1)
					_nDireita++
				ElseIf _nX <= 748
					_cItem := 'R' + SubStr( _cTexto , _nDireita , 1)
					_nDireita++
				ElseIf _nX <= 784
					_cItem := 'S' + SubStr( _cTexto , _nDireita , 1)
					_nDireita++
				ElseIf _nX <= 820
					_cItem := 'T' + SubStr( _cTexto , _nDireita , 1)
					_nDireita++
				ElseIf _nX <= 856
					_cItem := 'U' + SubStr( _cTexto , _nDireita , 1)
					_nDireita++
				ElseIf _nX <= 892
					_cItem := 'V' + SubStr( _cTexto , _nDireita , 1)
					_nDireita++
				ElseIf _nX <= 928
					_cItem := 'X' + SubStr( _cTexto , _nDireita , 1)
					_nDireita++
				ElseIf _nX <= 964
					_cItem := 'W' + SubStr( _cTexto , _nDireita , 1)
					_nDireita++
				ElseIf _nX <= 1000
					_cItem := 'Y' + SubStr( _cTexto , _nDireita , 1)
					_nDireita++
				ElseIf _nX <= 1036
					_cItem := 'Z' + SubStr( _cTexto , _nDireita , 1)
					_nDireita++
				End
			EndIf
			
			SUB->UB_FILIAL := _aItens[_nX,1]
			SUB->UB_ITEM   := _cItem
			SUB->UB_NUM    := _aItens[_nX,3]
			SUB->UB_PRODUTO:= _aItens[_nX,4]
			SUB->UB_DESCRI := _aItens[_nX,5]
			SUB->UB_QUANT  := _aItens[_nX,6]
			SUB->UB_VRUNIT := _aItens[_nX,7]
			SUB->UB_VLRITEM:= _aItens[_nX,8]
			SUB->UB_VLRMINI:= _aItens[_nX,9]
			SUB->UB_UM     := _aItens[_nX,10]
			SUB->UB_DTENTRE:= _aItens[_nX,11]
			SUB->UB_TES    := _aItens[_nX,12]
			SUB->UB_CF     := _aItens[_nX,13]
			SUB->UB_TABELA := _aItens[_nX,14]
			SUB->UB_LOCAL  := _aItens[_nX,15]
			SUB->UB_VALICM := _aItens[_nX,16]
			SUB->UB_VALIPI := _aItens[_nX,17]
			SUB->UB_BASEICM:= _aItens[_nX,18]
			SUB->UB_PRCTAB := _aItens[_nX,19]
			SUB->UB_PERCOM := _aItens[_nX,20]
			SUB->UB_COMISSA:= _aItens[_nX,21]
			SUB->UB_PRCPOL := _aItens[_nX,22]
			SUB->UB_CODCLI := _aItens[_nX,23]
			MsUnlock()
		Next
		End Transaction
		
		If Len(_aPedOk) > 0
			MsgBox(STR0023+SUA->UA_NUM,STR0024,'INFO') //'Orcamento criado com Sucesso! No. '###'Geracao de Orcamentos'
			DbSelectArea('SX1')
			If DbSeek("TMKR3A01",.F.).And.RecLock(Alias(),.F.)
				SX1->X1_CNT01 := ''
			EndIf
			If DbSeek("TMKR3A02",.F.).And.RecLock(Alias(),.F.)
				SX1->X1_CNT01 := 'Z'
			EndIf
			If DbSeek("TMKR3A03",.F.).And.RecLock(Alias(),.F.)
				SX1->X1_CNT01 := DtoC(dDatabase)
			EndIf
			If DbSeek("TMKR3A04",.F.).And.RecLock(Alias(),.F.)
				SX1->X1_CNT01 := DtoC(dDatabase)
			EndIf
			U_Tmkr3a(_aPedOk)
			T_TTMKA10('Refaz')
		EndIf
		
		Return(.T.)
EndCase

Return(Nil)
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
ฑฑณ Uso      ณ TTMKA10                                                    ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function MenuDef()
	Local aRotina := {	{STR0003	,"T_MenuDef1()"	,0	,1	,0	,.F.	}	,;	//"Pesquisar"
						{STR0004	,"T_MenuDef2()"	,0	,2	,0	,.T.	}	,;	//"Visualizar"
						{STR0005	,"T_MenuDef3()"	,0	,3	,0	,.T.	}	,;	//"Incluir"
						{STR0006	,"T_MenuDef4()"	,0	,4	,0	,.T.	}	,;	//"Alterar"
						{STR0007	,"T_MenuDef5()"	,0	,5	,0	,.T.	}	,;	//"Excluir"
						{STR0008	,"T_MenuDef6()"	,0	,6	,0	,.T.	}	}	//"Gera Orc."
Return(aRotina)
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณFun็๕es de atalho pois o MenuFuncional nใo permite itensณ
//ณcom parโmetros.                                         ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Template Function MenuDef1() ; T_TTMKA10( "Pesquisa" )		; Return(.T.)
Template Function MenuDef2() ; T_TTMKA10( "Visualizar" )	; Return(.T.)
Template Function MenuDef3() ; T_TTMKA10( "Incluir" ) 		; Return(.T.)
Template Function MenuDef4() ; T_TTMKA10( "Alterar" )		; Return(.T.)
Template Function MenuDef5() ; T_TTMKA10( "Excluir" )		; Return(.T.)
Template Function MenuDef6() ; T_TTMKA10( "GeraOrc" )		; Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCria_TLHA บAutor  ณMicrosiga           บ Data ณ  09/02/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP8                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Cria_TLHA()

DbSelectArea('SX3')
DbSetOrder(1)
DbSeek('LHA')
aFields := {}
While !Eof() .And. X3_ARQUIVO == 'LHA'
	If ALLTRIM(X3_CAMPO) $ _cCampos
		AADD(aFields,{X3_CAMPO,X3_TIPO,X3_TAMANHO,X3_DECIMAL})
	EndIf
	DbSkip()
End  
DbSeek('SA1')
While !Eof() .And. X3_ARQUIVO == 'SA1'
	If ALLTRIM(X3_CAMPO)+' ' $ 'A1_NOME '
		AADD(aFields,{X3_CAMPO,X3_TIPO,X3_TAMANHO,X3_DECIMAL})
		Exit
	EndIf
	DbSkip()
End  
cArq:=Criatrab(aFields,.T.)
DBUSEAREA(.t.,,cArq,"TLHA")

Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMonta_TLHAบAutor  ณMicrosiga           บ Data ณ  09/02/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP8                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Monta_TLHA()
Local _nX

DbSelectArea('SU7')
DbSetOrder(3)
DbSeek(xFilial('SU7')+Upper(cUserName))

For _nX := 1 To 2
	If _nX = 1
		cQueryCad := "SELECT Count(*) AS TOTAL FROM "+RetSqlName('LHA')+"  WHERE "
	Else
		cQueryCad := "SELECT DISTINCT "+_cCampos+ ", A1_NOME "
		cQueryCad += " FROM "+RetSqlName('LHA')+" , "
		cQueryCad += RetSqlName('SA1')+"  "
		cQueryCad += " WHERE "
		cQueryCad += " A1_COD+A1_LOJA = LHA_CLIENT+LHA_LOJA AND "
		cQueryCad += RetSqlName('SA1')+".D_E_L_E_T_ <> '*' AND "
	EndIf
	cQueryCad += RetSqlName('LHA')+".D_E_L_E_T_ <> '*' "
	If !Empty(SU7->U7_CODVEN) .And.;
		!(Upper(Rtrim(SubS(cUsuario,7,15))) $ Alltrim(SuperGetMv('MV_USUCANT')))
		cQueryCad += " AND LHA_VEND = '"+SU7->U7_CODVEN+"' "
	End
	TCQUERY cQueryCad NEW ALIAS "CAD"
	If _nX = 1
		_nCount := CAD->TOTAL
		DbCloseArea()
	EndIf
Next

TCSetField('CAD','LHA_EMISSA','D')

Dbselectarea("CAD")
DbGoTop()
ProcRegua(_nCount)

While CAD->(!EOF())
	IncProc()
	RecLock('TLHA',.T.)
	For _nX := 1 To Len(aFields)
		If aFields[_nX,2] = 'C'
			_cX := 'TLHA->'+aFields[_nX,1]+' := Alltrim(CAD->'+aFields[_nX,1]+')'
		Else
			_cX := 'TLHA->'+aFields[_nX,1]+' := CAD->'+aFields[_nX,1]
		EndIf
		_cX := &_cX
	Next
	MsUnLock()
	CAD->(dBSkip())
End  
Dbselectarea("CAD")
DbCloseArea()
Dbselectarea('TLHA')
DbGoTop()
_cIndex:=Criatrab(Nil,.F.)
_cChave:="LHA_NUMREQ"
Indregua('TLHA',_cIndex,_cChave,,,STR0025) //"Ordenando registros selecionados..."
DbSetIndex(_cIndex+ordbagext())
Dbselectarea('TLHA')
SysRefresh()
Return (Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ_fReplLHA บAutor  ณMicrosiga           บ Data ณ  09/02/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP8                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function _fReplLHA(_nVez)

LHA->LHA_ITEM   := T__fValAcols(_nVez,"LHA_ITEM")
LHA->LHA_CODREQ := T__fValAcols(_nVez,"LHA_CODREQ")
LHA->LHA_PRODUT := T__fValAcols(_nVez,"LHA_PRODUT")
LHA->LHA_DESCRI := T__fValAcols(_nVez,"LHA_DESCRI")
LHA->LHA_UM     := T__fValAcols(_nVez,"LHA_UM")
LHA->LHA_QUANT  := T__fValAcols(_nVez,"LHA_QUANT")
LHA->LHA_VALOR  := T__fValAcols(_nVez,"LHA_VALOR")
LHA->LHA_TOTAL  := T__fValAcols(_nVez,"LHA_TOTAL")
LHA->LHA_CODCLI := T__fValAcols(_nVez,"LHA_CODCLI")
LHA->LHA_NUMCLI := T__fValAcols(_nVez,"LHA_NUMCLI")
Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPesqLHA   บAutor  ณMicrosiga           บ Data ณ  09/02/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP8                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/   

Template Function PesqLHA()

CHKTEMPLATE("DCM")  

_cPesq := Space(6)
@ 220,005 TO 300,226 DIALOG oDlgPesC TITLE STR0026 //'Pesquisa Requisicao'
@ 003,002 SAY STR0027 //'Numero'
@ 002,025 GET _cPesq   SIZE 40,15 PICTURE "@!" VALID Pesqui(_cPesq)
@ 020,038 BUTTON "_Ok" SIZE 40,15 ACTION Close(oDlgPesC)

ACTIVATE DIALOG oDlgPesC CENTERED
Return(.T.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPesqui    บAutor  ณMicrosiga           บ Data ณ  09/02/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP8                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Pesqui(_cPes)
Return(TLHA->(DbSeek(_cPes)))
