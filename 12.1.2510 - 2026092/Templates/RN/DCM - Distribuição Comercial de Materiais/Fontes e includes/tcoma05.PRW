#INCLUDE "tcoma05.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "TOPCONN.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTCOMA05   บAutor  ณEwerton Carlos Tomazบ Data ณ  12/04/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Nova tabela de Negociacao                                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP7                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Template Function TCOMA05(_cOper)
Local _nVez, _nX, _nX2, j, i
Static _lPrim
Private cCalcFrete := ""

If _lPrim==Nil
	_lPrim:=.t.
Endif
Dbselectarea("LH1")
private cString   := alias(),;
        cCadastro := cTitulo := posicione("SX2",1,alias(),"X2_CHAVE+' - '+X2_NOME"),;
        _cTudoOk  := "TudoOk",     _cLinhaOk := "LinhaOk", _cRefresh := "Refresh", _cRefresh2 := "Refresh2",;
        _cVisual  := "VISUALIZAR", _cIncluir := "INCLUIR", _cAlterar := "ALTERAR", _cExcluir  := "EXCLUIR",;
        _cReajust := "Reajuste",   _cImporta := "Importa", _cExporta := "Exporta", _cImprime  := "Imprime", cPerg := "TCOMA05",;
        inclui    := altera := _lAtend := .f., _cDuplica := "Duplica"

Private aSize := {}
Private aObjects := {}
Private aPosObj  := {}
Private aSizeAut := {}
Private aPosGet  := {}
Private aInfo    := {}

aSizeAut := MsAdvSize()

aObjects := {}
AAdd( aObjects, { 100, 100, .T., .t. } )
AAdd( aObjects, { 100, 100, .t., .t. } )
AAdd( aObjects, { 100, 015, .t., .f. } )

aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 }

aPosObj := MsObjSize( aInfo, aObjects )
aPosGet := MsObjGetPos(aSizeAut[3]-aSizeAut[1],315,{{003,043,083,123,163,203}} )
nLinIni := aPosObj[ 3, 1 ]
Aadd(aSize,110)

Do Case
	Case _cOper == nil // Chamada do menu
		
		cDelFunc := ".T."
		
		aRotina := MenuDef()
		//		{"Imp.Texto","u_RFATM09()",0,11}}
		
		mBrowse( 6,1,22,75,'LH0')
		
	Case _cOper == _cLinhaOk
		_lLinhaOk := .T.
		_nSoma := _nSoma2 := 0
		_nPosPreco  := AsCan(aHeader,{|x|Alltrim(Upper(x[2]))=='LH1_PRECO'})
		_nPosTotal  := AsCan(aHeader,{|x|Alltrim(Upper(x[2]))=='LH1_TOTAL'})
		for _nVez:=1 to len(aCols)
			If !aCols[_nVez,nUsado+1]
				_nSoma += aCols[_nVez,_nPosPreco]
				_nSoma2+= aCols[_nVez,_nPosTotal]
			Endif
		next
		
		If _nSoma <> m->LH0_TOTTAB .Or. _nSoma2 <> M->LH0_TOTGER .Or. m->LH0_TOTCUS == 0
			
			SomaLinha()
			
			_cMen    := ''
			
			for _nVez:=1 to len(aCols)
				If !aCols[n,nUsado+1] .And. _nVez <> n
					If aCols[n,2] = aCols[_nVez,2]
						_cMen += STR0011+Chr(13) //"Codigo do Produto ja Informado !"
					Endif
				Endif
			next
			
			_nPosCusto  := AsCan(aHeader,{|x|Alltrim(Upper(x[2]))=='LH1_CUSTO'})
			_nPosPreco  := AsCan(aHeader,{|x|Alltrim(Upper(x[2]))=='LH1_PRECO'})
			
			If !aCols[n,nUsado+1]
				If Empty(aCols[n,2])
					_cMen += STR0012+Chr(13) //"Informe o Codigo do Produto !"
				ElseIf Empty(aCols[n,4])
					_cMen += STR0013+Chr(13) //"Informe a Unidade de Medida !"
				ElseIf Empty(aCols[n,_nPosCusto])
					_cMen += STR0014+Chr(13) //"Informe o Custo Unitario !"
				ElseIf Empty(aCols[n,_nPosPreco])
					_cMen += STR0015+Chr(13) //"Informe o Preco Unitario !"
				Endif
			Endif
			
			If !Empty(_cMen)
				MsgStop(_cMen)
				_lLinhaOk := .F.
			Endif
			
			oGetDados:Refresh()
			oGetDados:oBrowse:Refresh()
			
			@ nLinIni,aPosGet[1,1] say STR0016 SIZE 60,40 //'Total Custo'
			@ nLinIni,aPosGet[1,2] get M->LH0_TOTCUS picture '@ER 9999,999.99' SIZE 40,40 when .f.
			@ nLinIni,aPosGet[1,3] say STR0017 SIZE 60,40 //'Total Venda'
			@ nLinIni,aPosGet[1,4] get M->LH0_TOTGER picture '@ER 9999,999.99'  SIZE 40,40 when .f.
			@ nLinIni,aPosGet[1,5] say STR0018 SIZE 60,40 //'Markup Total'
			@ nLinIni,aPosGet[1,6] get m->LH0_MKCUSV picture '@ER 999.99'       SIZE 40,40 when .f.
			
		Endif
		return _lLinhaOk
		
	Case _cOper==_cTudoOk
		_lTudoOk:=.t.
		
		SomaLinha()
		
		If Empty(M->LH0_OBS1)
			M->LH0_OBS1 := STR0019+Space((TamSx3('LH0_OBS1')[1])-9) //'VALIDADE:'
		Endif
		
		@ 000,000 TO 085,400 DIALOG _oDlgObs TITLE STR0020 //"Observacoes"
		@ 010,005 get M->LH0_OBS1 size 160,40
		@ 025,005 get M->LH0_OBS2 size 160,40
		@ 025,170 BmpButton Type 1 Action Close(_oDlgObs)
		Activate DIALOG _oDlgObs centered
		
		return _lTudoOk
	Case _cOper==_cReFresh
		_cField := readvar()
		
		_nPosCusto  := AsCan(aHeader,{|x|Alltrim(Upper(x[2]))=='LH1_CUSTO'})
		_nPosPreco  := AsCan(aHeader,{|x|Alltrim(Upper(x[2]))=='LH1_PRECO'})
		_nPosTotal  := AsCan(aHeader,{|x|Alltrim(Upper(x[2]))=='LH1_TOTAL'})
		_nPosMkPol  := AsCan(aHeader,{|x|Alltrim(Upper(x[2]))=='LH1_MKPOL'})
		_nPosMkAtu  := AsCan(aHeader,{|x|Alltrim(Upper(x[2]))=='LH1_MKATU'})
		_nPosQuant  := AsCan(aHeader,{|x|Alltrim(Upper(x[2]))=='LH1_QUANT'})
		_nPosDescPro:= AsCan(aHeader,{|x|Alltrim(Upper(x[2]))=='LH1_DESCPR'})
		_nPosCodCli := AsCan(aHeader,{|x|Alltrim(Upper(x[2]))=='LH1_CODCLI'})
		_nPosNomMar := AsCan(aHeader,{|x|Alltrim(Upper(x[2]))=='LH1_NOMMAR'})
		_nPosEstoque:= AsCan(aHeader,{|x|Alltrim(Upper(x[2]))=='LH1_ESTOQU'})
		_nPosUM     := AsCan(aHeader,{|x|Alltrim(Upper(x[2]))=='LH1_UM'})
		
		Posicione('SB1',1,xFilial('SB1')+aCols[n,2],'')
		Posicione('LH7',1,xFilial('LH7')+aCols[n,2],'')
		_cUnid := Iif(Empty(aCols[n,_nPosUM]),SB1->B1_UM,aCols[n,_nPosUM])
		If lower(alltrim(_cField))=="m->lh1_um" .And. aCols[n,_nPosUM] <> &_cField
			_cUnid := T_TTMKA09b(SB1->B1_COD)
			_cUnid := IiF(Empty(_cUnid),SB1->B1_UM,_cUnid)
			M->LH1_UM   := _cUnid
			aCols[n,_nPosUM] := _cUnid
		Endif
		_nQtdEmb := Iif(_cUnid == SB1->B1_UM, 1,;
		                Iif(_cUnid == SB1->B1_SEGUM, SB1->B1_CONV,;
		                    Iif(_cUnid == SB1->B1_UM3, SB1->B1_UM3FAT,;
		                        Iif(_cUnid == SB1->B1_UM4, SB1->B1_UM4FAT, 1))))
		Do Case
			Case lower(alltrim(_cField))=="m->lh0_client"
				M->LH0_NOME := Posicione('SA1',1,xFilial('SA1')+M->LH0_CLIENT+Alltrim(M->LH0_LOJA),'A1_NOME')
				M->LH0_LOJA := SA1->A1_LOJA
				M->LH0_VEND := SA1->A1_VEND
				M->LH0_NOMEVE := Posicione('SA3',1,xFilial('SA3')+M->LH0_VEND,'A3_NOME')
			Case lower(alltrim(_cField))=="m->lh0_vend"
				M->LH0_NOMEVE := Posicione('SA3',1,xFilial('SA3')+M->LH0_VEND,'A3_NOME')
			Case lower(alltrim(_cField))=="m->lh1_produt"
				Posicione('SB1',1,xFilial('SB1')+M->LH1_PRODUT,'')
				Posicione('LH7',1,xFilial('LH7')+M->LH1_PRODUT,'')
				aCols[n,3] := SB1->B1_DESC
				aCols[n,_nPosUM] := SB1->B1_UM
				aCols[n,_nPosCusto] := PegaCusto() * _nQtdEmb
				If !Empty(M->LH0_CONDPA)
					aCols[n,_nPosCusto] := aCols[n,_nPosCusto] * (1+(Posicione('SE4',1,xFilial('SE4')+M->LH0_CONDPA,"E4_ACREDCM")/100))
				Endif
				Posicione('SU7',3,xFilial('SU7')+M->LH0_NOMEVE,'U7_POSTO')
				Posicione('SU0',1,xFilial('SU0')+IIf(!Empty(SA1->A1_GRUPOAT),SA1->A1_GRUPOAT,SU7->U7_POSTO),'U0_TABMIN')
				If SU0->U0_TABMIN > 0
					aCols[n,_nPosMkPol] := &('LH7->LH7_MKP'+StrZero(SU0->U0_TABMIN,2))
				Else
					aCols[n,_nPosMkPol] := LH7->LH7_MKP01
				Endif
				_aMarkup := {}
				For _nX := 1 To 10
					_cG := "M->LH0_GRP"+StrZero(_nX,2)
					_cM := "M->LH0_MKP"+StrZero(_nX,2)
					AaDd(_aMarkup,{&_cG,&_cM})
				Next
				If Ascan(_aMarkup,{|x|x[1]==SubStr(SB1->B1_GRUPO,1,4)}) > 0
					aCols[n,_nPosMkAtu] := Iif(aCols[n,_nPosMkAtu]<>0,aCols[n,_nPosMkAtu],_aMarkup[Ascan(_aMarkup,{|x|x[1]==SubStr(SB1->B1_GRUPO,1,4)}),2])
				ElseIf M->LH0_MKGER > 0
					aCols[n,_nPosMkAtu] := Iif(aCols[n,_nPosMkAtu]<>0,aCols[n,_nPosMkAtu],M->LH0_MKGER)
				ElseIf SU0->U0_TABMIN > 0
					aCols[n,_nPosMkAtu] := Iif(aCols[n,_nPosMkAtu]<>0,aCols[n,_nPosMkAtu],&('LH7->LH7_MKP'+StrZero(SU0->U0_TABMIN,2)))
				Endif
				aCols[n,_nPosPreco]   := (aCols[n,_nPosCusto] / ((100-aCols[n,_nPosMkAtu])/100)) * _nQtdEmb
				aCols[n,_nPosQuant]   := 1
				aCols[n,_nPosTotal]   := aCols[n,_nPosPreco]
				//aCols[n,_nPosDescPro] := LH7->LH7_PYDESC
				aCols[n,_nPosCodCli]  := Posicione('LH5',1,xFilial('LH5')+M->LH0_CLIENT+M->LH1_PRODUT,'LH5_CODCLI')
				aCols[n,_nPosNomMar]  := SB1->B1_FABRIC
				Posicione('SB2',1,xFilial('SB2')+SB1->B1_COD,'')
				If T_BuscaSalCon(LH0->LH0_CLIENT,SB1->B1_COD) > 0
					_nMix    := T_BuscaSalCon(LH0->LH0_CLIENT,SB1->B1_COD)
					_nDisp   := _nMix
				Else
					_nMix    := T_BuscaSalCon('',SB1->B1_COD)
					_nDisp   := SaldoMov() - _nMix
				Endif
				aCols[n,_nPosEstoque] := _nDisp
			Case lower(alltrim(_cField))=="m->lh1_um"
				aCols[n,_nPosCusto] := PegaCusto()
				If !Empty(M->LH0_CONDPA)
					aCols[n,_nPosCusto] := aCols[n,_nPosCusto] * (1+(Posicione('SE4',1,xFilial('SE4')+M->LH0_CONDPA,"E4_ACREDCM")/100))
				Endif
				aCols[n,_nPosCusto]  := aCols[n,_nPosCusto] * _nQtdEmb
				aCols[n,_nPosPreco]  := (aCols[n,_nPosCusto] / ((100-aCols[n,_nPosMkAtu])/100)) 
			Case lower(alltrim(_cField))=="m->lh1_mkatu"
				// Atualiza Preco
				_nPreCus    := aCols[n,_nPosCusto] / ((100-M->LH1_MKATU)/100)
				If !Empty(M->LH0_CONDPA)
					_nPreCus := _nPreCus * (1+(Posicione('SE4',1,xFilial('SE4')+M->LH0_CONDPA,"E4_ACREDCM")/100))
				Endif
				aCols[n,_nPosPreco] := _nPreCus
				aCols[n,_nPosPreco] := aCols[n,_nPosPreco] 
				aCols[n,_nPosTotal] := Round(aCols[n,_nPosPreco],2) * aCols[n,_nPosQuant]
			Case lower(alltrim(_cField))=="m->lh1_preco"
				// Atualiza Markup Atual
				_nPreCus   := aCols[n,_nPosCusto] 
				If !Empty(M->LH0_CONDPA)
					_nPreCus := _nPreCus * (1+(Posicione('SE4',1,xFilial('SE4')+M->LH0_CONDPA,"E4_ACREDCM")/100))
				Endif
				aCols[n,_nPosMkAtu] := ((M->LH1_PRECO-_nPreCus) / M->LH1_PRECO) * 100
				aCols[n,_nPosTotal] := Round(M->LH1_PRECO,2) * aCols[n,_nPosQuant]
			Case lower(alltrim(_cField))=="m->lh1_custo"
				// Atualiza Markup Atual
				_nPreCus   := M->LH1_CUSTO * _nQtdEmb
				_nPreco    := aCols[n,_nPosPreco] * _nQtdEmb
				If !Empty(M->LH0_CONDPA)
					_nPreCus := _nPreCus * (1+(Posicione('SE4',1,xFilial('SE4')+M->LH0_CONDPA,"E4_ACREDCM")/100))
				Endif
				aCols[n,_nPosMkAtu] := ((_nPreco-_nPreCus) / _nPreco) * 100
				aCols[n,_nPosTotal] := Round(_nPreco,2) * aCols[n,_nPosQuant]
			Case lower(alltrim(_cField))=="m->lh1_quant"
				// Atualiza Valor Total do Item
				aCols[n,_nPosTotal] := Round(aCols[n,_nPosPreco],2) * M->LH1_QUANT
		EndCase
		/*
		If M->LH1_CALCFRE = 'S'
		   _cEst := Posicione('SA1',1,xFilial('SA1')+M->LH0_CLIENT+M->LH0_LOJA,'A1_EST')
		   _cMun := SA1->A1_MUN
		   DbSelectArea('SZC')
		   DbSetOrder(1)
		   _nFre := 0
		   If DbSeek(xFilial('SZC')+_cEst+_cMun+SB1->B1_GRUPO)
		      _nFre := SZC->ZC_TAXAFRE
		   ElseIf DbSeek(xFilial('SZC')+_cEst+_cMun+'????')
		      _nFre := SZC->ZC_TAXAFRE
		   ElseIf DbSeek(xFilial('SZC')+_cEst+'TODOS'+Space(30)+SB1->B1_GRUPO)
		      _nFre := SZC->ZC_TAXAFRE
		   ElseIf DbSeek(xFilial('SZC')+_cEst+'TODOS'+Space(30)+'????')
		      _nFre := SZC->ZC_TAXAFRE
		   Endif
		   If _nFre > 0
		      aCols[n,_nPosPreco] := aCols[n,_nPosPreco] * (1+(_nFre/100))
		      aCols[n,_nPosMkAtu] := ((aCols[n,_nPosPreco]-aCols[n,_nPosCusto]) / aCols[n,_nPosPreco]) * 100
		      aCols[n,_nPosTotal] := Round(aCols[n,_nPosPreco],2) * aCols[n,_nPosQuant]
		   Endif
		   DbSelectArea('LH1')
		Endif
		*/
		oGetDados:Refresh()
		oGetDados:oBrowse:Refresh()
		return .t.
		
	Case _cOper==_cReFresh2
		_cField:=readvar()
		
		_nPosCusto  := AsCan(aHeader,{|x|Alltrim(Upper(x[2]))=='LH1_CUSTO'})
		_nPosPreco  := AsCan(aHeader,{|x|Alltrim(Upper(x[2]))=='LH1_PRECO'})
		_nPosTotal  := AsCan(aHeader,{|x|Alltrim(Upper(x[2]))=='LH1_TOTAL'})
		_nPosMkAtu  := AsCan(aHeader,{|x|Alltrim(Upper(x[2]))=='LH1_MKATU'})
		_nPosQuant  := AsCan(aHeader,{|x|Alltrim(Upper(x[2]))=='LH1_QUANT'})
		_cEst := Posicione('SA1',1,xFilial('SA1')+M->LH0_CLIENT+M->LH0_LOJA,'A1_EST')
		_cMun := SA1->A1_MUN
		
		If SubStr(Lower(alltrim(_cField)),1,10) == 'm->lh0_grp'
			_cX := "M->LH0_DESG"+SubStr(Lower(alltrim(_cField)),11,2)+" := '"+;
			Posicione('SBM',1,xFilial('SBM')+&_cField,'BM_DESC')+"' "
			_cX := &_cX
		Endif
		
		For _nX := 1 To Len(aCols)
			If aCols[_nX,Len(aHeader)+1]
				Loop
			Endif
			Posicione('SB1',1,xFilial('SB1')+aCols[_nX,2],'')
			Posicione('LH7',1,xFilial('LH7')+aCols[_nX,2],'')
			_cUnid   := Iif(Empty(aCols[_nX,4]),SB1->B1_UM,aCols[_nX,4])
			_nQtdEmb := IiF(_cUnid=SB1->B1_UM,1,;
			IiF(_cUnid=SB1->B1_SEGUM,SB1->B1_CONV,;
			IiF(_cUnid=SB1->B1_UM3,SB1->B1_UM3FAT,;
			IiF(_cUnid=SB1->B1_UM4,SB1->B1_UM4FAT,1))))
			
			_nMarkup := 0
			aCols[_nX,_nPosCusto] := PegaCusto() * _nQtdEmb
			If !Empty(M->LH0_CONDPA)
				aCols[_nX,_nPosCusto] := aCols[_nX,_nPosCusto] * (1+(Posicione('SE4',1,xFilial('SE4')+M->LH0_CONDPA,"E4_ACREDCM")/100))
			Endif
			aCols[_nX,_nPosPreco] := aCols[_nX,_nPosCusto] / ((100-aCols[_nX,_nPosMkAtu])/100)
			aCols[_nX,_nPosMkAtu] := ((aCols[_nX,_nPosPreco]-aCols[_nX,_nPosCusto]) / aCols[_nX,_nPosPreco]) * 100
			aCols[_nX,_nPosTotal] := aCols[_nX,_nPosPreco] * aCols[_nX,_nPosQuant]
			For _nX2 := 1 To 10
				_cG := "M->LH0_GRP"+StrZero(_nX2,2)
				_cM := "M->LH0_MKP"+StrZero(_nX2,2)
				If &_cG = SB1->B1_GRUPO
					_nMarkup := &_cM
					If _nMarkup > 0
						aCols[_nX,_nPosMkAtu] := _nMarkup
					Else
						aCols[_nX,_nPosMkAtu] := Iif(aCols[_nX,_nPosMkAtu]<>0,aCols[_nX,_nPosMkAtu],M->LH0_MKGER)
					Endif
					aCols[_nX,_nPosPreco]   := (aCols[_nX,_nPosCusto] / ((100-aCols[_nX,_nPosMkAtu])/100)) * _nQtdEmb
					aCols[_nX,_nPosTotal]   := aCols[_nX,_nPosPreco] * aCols[_nX,_nPosQuant]
				Endif
			Next
			/*
			If M->LH1_CALCFRE = 'S'
			   DbSelectArea('SZC')
			   DbSetOrder(1)
			   _nFre := 0
			   If DbSeek(xFilial('SZC')+_cEst+_cMun+SB1->B1_GRUPO)
			      _nFre := SZC->ZC_TAXAFRE
			   ElseIf DbSeek(xFilial('SZC')+_cEst+_cMun+'????')
			      _nFre := SZC->ZC_TAXAFRE
			   ElseIf DbSeek(xFilial('SZC')+_cEst+'TODOS'+Space(30)+SB1->B1_GRUPO)
			      _nFre := SZC->ZC_TAXAFRE
			   ElseIf DbSeek(xFilial('SZC')+_cEst+'TODOS'+Space(30)+'????')
			      _nFre := SZC->ZC_TAXAFRE
			   Endif
			   If _nFre > 0
			      aCols[_nX,_nPosPreco] := aCols[_nX,_nPosPreco] * (1+(_nFre/100))
			      aCols[_nX,_nPosMkAtu] := ((aCols[_nX,_nPosPreco]-aCols[_nX,_nPosCusto]) / aCols[_nX,_nPosPreco]) * 100
			      aCols[_nX,_nPosTotal] := aCols[_nX,_nPosPreco] * aCols[_nX,_nPosQuant]
			   Endif
			   DbSelectArea('LH0')
			Endif
			*/
		Next
		oGetDados:Refresh()
		oGetDados:oBrowse:Refresh()
		Return .t.

	Case "imprime"$lower(alltrim(_cOper))
		cPerg := PADR("TCOMR02",Len(SX1->X1_GRUPO))
		if sx1->(dbseek(cPerg+"01",.f.).and.reclock(alias(),.f.))
			sx1->x1_cnt01:= LH0->LH0_COD
			sx1->(msunlock())
		Endif
		If sx1->(dbseek(cPerg+"02",.f.).and.reclock(alias(),.f.))
			sx1->x1_cnt01:= LH0->LH0_COD
			sx1->(msunlock())
		Endif
		DbSelectArea('LH0')
		Pergunte(cPerg,.f.)
		tamanho     := "P"
		_nLin       := 99
		li          := 0
		_nLimiteLin := 60
		limite      := 80
		titulo      := STR0032 //"PROPOSTA COMERCIAL/PARCERIA"
		cDesc1      := STR0033 //"Este programa ira emitir a lista de precos de   "
		cDesc2      := STR0034 //"acordo com a(s) tabela(s) selecionadas          "
		cDesc3      := ""
		m_pag       := 1
		aReturn     := { STR0035, 1,STR0036, 1, 2, 1,"",1 } //"Especial"###"Administracao"
		wnrel       := nomeprog:="TCOMR02"
		nLastKey    := 0
		cString     := "LH0"
		cabec1      := cabec2:=""
		
		wnrel := SetPrint(cString,wnrel,cPerg,@Titulo,cDesc1,cDesc2,cDesc3,.t.,,.t.,tamanho)
		If nLastKey == 27
			Return
		Endif
		RptStatus({|| RptDetail() })
		If nLastKey == 27
			Return
		Endif
		Return

	Case "reajuste"$lower(alltrim(_cOper))
		Private _cMark := GetMark()
		Private cCadastro:=STR0037 //"Reajuste de Precos"
		Private cDelFunc := ".T."
		cString:="LH1"
		Private _lFiltra:=.f.
		Private _lSair:=.f.
		Private cQueryCad := ""
		Private aFields := {}
		Private cArq    := ""
		Private _nCount := 0
		Private _cCampos  := "LH1_ITEM,LH1_PRODUT,B1_DESC,LH1_UM,LH1_PRECO,LH1_NOMMAR,LH1_QUANT,LH1_TOTAL"
		//        Private _cArqSel  := 'LH1/SB1'
		Private _aArqSel  := {'LH1','SB1'}
		Private _cArqSel2 := RetSqlName('LH1')+', '+RetSqlName('SB1')
		Private _cOrdem   := ''
		Private _nAcrescimo := _nDesconto := _nMarkup := 0
		Private _cAcrescimo := _cDesconto := _cMarkup := Space(2)
		Private _cMarca   := ''
		Private _aMarcas  := {}
		
		@ 100,005 TO 500,900 DIALOG oDlgRea TITLE cCadastro
		aCampos := {}
		DbSelectArea('SX3')
		DbSetOrder(1)
		AADD(aCampos,{'000','LH1_OK','',''})
		For _nX := 1 To Len(_aArqSel)
			DbSeek(_aArqSel[_nX])
			While !Eof() .And. X3_ARQUIVO = _aArqSel[_nX]
				If ALLTRIM(X3_CAMPO) $ _cCampos
					AADD(aCampos,{StrZero(AT(ALLTRIM(X3_CAMPO),_cCampos),3,0),Alltrim(X3_CAMPO),Alltrim(X3_TITULO),Iif(X3_TIPO='N',X3_PICTURE,'')})
				Endif
				DbSkip()
			End  
		Next
		ASort(aCampos,,,{|x,y|x[1]<y[1]})
		
		aCampos2 := {}
		For _nX := 1 To Len(aCampos)
			AADD(aCampos2,{aCampos[_nX,2],aCampos[_nX,3],aCampos[_nX,4]})
		Next
		aCampos := {}
		aCampos := aCampos2
		Cria_TLH1()
		DbSelectArea('TLH1')
		@ 006,005 TO 190,325 BROWSE "TLH1" MARK "LH1_OK" FIELDS aCampos Object _oBrwRea
		@ 006,330 BUTTON STR0038   SIZE 40,15 ACTION Confirma() //"_Confirma"
		@ 026,330 BUTTON STR0039   SIZE 40,15 ACTION MarcaTudo() //"_Marca/Desmar"
		@ 183,330 BUTTON STR0040   SIZE 40,15 ACTION Close(oDlgRea) //"_Sair"
		
		Processa({|| Monta_TLH1() } ,STR0041) //"Selecionando Informacoes da Tabela..."
		
		_oBrwRea:bMark := {|| Marcar()}
		
		@ 193,005 SAY STR0042+Alltrim(Str(_nCount,6,0))+STR0043 //"Foram processados "###" registro(s)"
		@ 046,330 SAY STR0044 //"Acrescimo (%)"
		@ 056,335 GET _cAcrescimo SIZE 30,20
		@ 066,330 SAY STR0045 //"Desconto  (%)"
		@ 076,335 GET _cDesconto  SIZE 30,20
		@ 086,330 SAY STR0046 //"Markup       "
		@ 096,335 GET _cMarkup    SIZE 30,20
		@ 121,330 Say STR0047 //"Marcas"
		@ 131,330 COMBOBOX _cMarca ITEMS _aMarcas SIZE 100,20
		
		ACTIVATE DIALOG oDlgRea CENTERED
		
		DbSelectArea("TLH1")
		DbCloseArea()
		FErase(cArq+OrdBagExt())
		
		Return
	Case "importa"$lower(alltrim(_cOper))
		cPerg:= Padr("TCOR2B",Len(SX1->X1_GRUPO))
		If !pergunte(cPerg,.T.)
			Return(.T.)
		Endif
		Processa({|| Importa() } ,STR0049) //"Selecionando Informacoes do Orcamento..."
		Return
	Case "exporta"$lower(alltrim(_cOper))
		//_cPerg := "COMA8B"
		_cPerg := Padr("COMA05",Len(SX1->X1_GRUPO))
		If !Empty(LH0->LH0_NUMORC)
			If sx1->(DbSeek(_cPerg+"01",.f.).and.RecLock(alias(),.f.))
				sx1->x1_cnt01:= DTOC(dDatabase)
				sx1->(msunlock())
			Endif
			If sx1->(DbSeek(_cPerg+"02",.f.).and.RecLock(alias(),.f.))
				sx1->x1_cnt01:= DTOC(dDatabase)
				sx1->(msunlock())
			Endif
			If sx1->(DbSeek(_cPerg+"04",.f.).and.RecLock(alias(),.f.))
				sx1->x1_cnt01:= LH0->LH0_NUMORC
				sx1->(msunlock())
			Endif
		Endif
		If !Pergunte(_cPerg,.T.)
			Return(.T.)
		Endif
		DbSelectArea('LH4')
		DbSetOrder(2)
		_cProxNum := ''
		If DbSeek(xFilial('LH4')+LH0->LH0_CLIENT+LH0->LH0_LOJA)
			_cProxNum := LH4->LH4_COD
		Else
			If !MsgYesNo(STR0050) //'Nao existe negociacao/contrato para este cliente, Deseja criar ?'
				Return(.T.)
			Else
				_cProxNum := GetSx8Num('LH4','LH4_COD')
			Endif
		Endif
		Processa({|| Exporta(_cProxNum) } ,STR0041) //"Selecionando Informacoes da Tabela..."
		Return
	Case "duplica"$lower(alltrim(_cOper))
		cPerg:= Padr("TCOMR2C", Len(SX1->X1_GRUPO))
		If !pergunte(cPerg,.T.)
			Return(.T.)
		Endif
		If !MsgYesNo(STR0054+MV_PAR01+' ?') //'Confirma a Duplicacao do Contrato para o Cliente: '
			Return(.T.)
		Endif
		Processa({|| Duplica() } ,STR0049) //"Selecionando Informacoes do Orcamento..."
		Return
	Case "pegalinha"$lower(alltrim(_cOper))
		Return(StrZero(val(aCols[Len(aCols)-1,1])+1,4,0))
	Otherwise
		msgbox("T_TCOMA05: Nao ha previsao para: "+_cOper)
EndCase
Return

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
ฑฑณ Uso      ณ TCOMA05                                                    ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/                                      
Static Function MenuDef()               
Local xRetorno   
Local nX      := 0
Local aRotina := {	{ STR0001	,"AxPesqui"		,0	,1	,0	,.F.	}	,;	//"Pesquisa"
						{ STR0002	,"T_LH1C1()"	,0	,2	,0	,.T.	}	,;	//"Visual"
						{ STR0003	,"T_LH1C2()"	,0	,3	,0	,.T.	}	,;	//"Inclui"
						{ STR0004	,"T_LH1C3()"	,0	,4	,20	,.T.	}	,;	//"Altera"
						{ STR0005	,"T_LH1C4()"	,0	,5	,21	,.T.	}	,;	//"Exclui"
						{ STR0006	,"T_A051()"		,0	,6	,0	,.T.	}	,;	//"Imprimir"
						{ STR0007	,"T_A052()"		,0	,7	,0	,.T.	}	,;	//"Reajustar"
						{ STR0008	,"T_A053()"		,0	,8	,0	,.T.	}	,;	//"Importar"
						{ STR0009	,"T_A054()"		,0	,9	,0	,.T.	}	,;	//"Exportar"
						{ STR0010	,"T_A055()"		,0	,10	,0	,.T.	}	}	//"Duplicar" 
						
If FindFunction("U_DCMMDTCM05")
	xRetorno := U_DCMMDTCM05(aRotina)
	If ValType(xRetorno) == "A"
	   For nX := 1 to len(xRetorno)
         If Len(xRetorno[nX]) == 6
            AADD(aRotina,xRetorno[nX]) 
         EndIf            
       Next nX 		
	EndIf
EndIf								
Return	aRotina

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณFun็๕es de atalho pois o MenuFuncional nใo permite itensณ
//ณcom parโmetros.                                         ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Template Function LH1C1(); LH1Cadastro("VISUALIZAR"); Return(.T.)
Template Function LH1C2(); LH1Cadastro("INCLUIR");    Return(.T.)
Template Function LH1C3(); LH1Cadastro("ALTERAR");    Return(.T.)
Template Function LH1C4(); LH1Cadastro("EXCLUIR");    Return(.T.)
Template Function A051();  T_TCOMA05("Imprime");      Return(.T.)
Template Function A052();  T_TCOMA05("Reajuste");     Return(.T.)
Template Function A053();  T_TCOMA05("Importa");      Return(.T.)
Template Function A054();  T_TCOMA05("Exporta");      Return(.T.)
Template Function A055();  T_TCOMA05("Duplica");      Return(.T.)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLH1CadastroบAutor  ณMicrosiga           บ Data ณ  08/02/05   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                             บฑฑ
ฑฑบ          ณ                                                             บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                          บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function LH1Cadastro(cOpcao)
Local _ni, _nVez, _nX

SetKey(119 , { || vertotal() }) // F8
SetKey(120 , { || T_TTMKC01(aCols[n,2]) }) // F9

Do Case
	Case cOpcao=="INCLUIR"; nOpcE:=3 ; nOpcG:=3
	Case cOpcao=="ALTERAR"; nOpcE:=3 ; nOpcG:=3
	Case cOpcao=="EXCLUIR"; nOpcE:=2 ; nOpcG:=2
	Case cOpcao=="VISUALIZAR"; nOpcE:=2 ; nOpcG:=2
EndCase
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Cria variaveis M->????? da Enchoice                          ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
RegToMemory("LH0",(cOpcao=="INCLUIR"))
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Cria aHeader e aCols da GetDados                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
nUsado:=0
DbSelectArea("SX3")
DbSeek("LH1")
aHeader:={}
While !Eof().And.(x3_arquivo=="LH1")
	If Alltrim(x3_campo)$"LH1_CODTAB"
		DbSkip()
		Loop
	Endif
	If X3USO(x3_usado).And.cNivel>=x3_nivel
		nUsado:=nUsado+1
		Aadd(aHeader,{ TRIM(x3_titulo), x3_campo, x3_picture,;
		     x3_tamanho, x3_decimal,"T_TCOMA05(_cRefresh)",;
		     x3_usado, x3_tipo, x3_arquivo, x3_context } )
	Endif
	DbSkip()
End

If cOpcao=="INCLUIR"
	aCols:={Array(nUsado+1)}
	aCols[1,nUsado+1]:=.F.
	For _ni:=1 to nUsado
		aCols[1,_ni]:=CriaVar(aHeader[_ni,2])
	Next
	M->LH0_DTCAD := Date()
Else
	aCols:={}
	DbSelectArea("LH1")
	DbSetOrder(1)
	DbSeek(xFilial("LH1")+M->LH0_COD)
	While LH1->(! Eof()) .AND. LH1->LH1_FILIAL == xFilial("LH1") .AND. LH1->LH1_CODTAB == M->LH0_COD
		AADD(aCols,Array(nUsado+1))
		For _ni:=1 to nUsado
			aCols[Len(aCols),_ni]:=FieldGet(FieldPos(aHeader[_ni,2]))
		Next
		aCols[Len(aCols),nUsado+1]:=.F.
		DbSkip()
	End
Endif
If Len(aCols)>0
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Executa a Modelo 3                                           ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	cTitulo:=STR0055 //"Manutencao na Tabela de Negociacao"
	cAliasEnchoice:="LH0"
	cAliasGetD:="LH1"
	cLinOk:="T_TCOMA05(_cLinhaOk)"
	cTudOk:="T_TCOMA05(_cTudoOk)"
	cFieldOk:="AllwaysTrue()"
	aCpoEnchoice:={"LH0_CLIENT"}
	_lRet := Modelo3Meu(cTitulo,cAliasEnchoice,cAliasGetD,aCpoEnchoice,cLinOk,cTudOk,nOpcE,nOpcG,cFieldOk,,9999)
	//	_lRet:=Modelo3(cTitulo,cAliasEnchoice,cAliasGetD,aCpoEnchoice,cLinOk,cTudOk,nOpcE,nOpcG,cFieldOk,,9999)
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Executar processamento                                       ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If _lRet
		_nOrdLH0:=LH0->(indexord())
		LH0->(dbsetorder(1))
		Do Case
			Case cOpcao=="INCLUIR"
				_nItem:=1
				For _nVez:=1 to Len(aCols)
					// so appenda se nao estiver marcado e nao existir
					If _nVez = 1 .And. !LH0->(DbSeek(xfilial("LH0")+M->LH0_COD))
						RecLock('LH0',.T.)
						LH0->LH0_FILIAL :=xfilial("LH0")
						LH0->LH0_COD    :=M->LH0_COD
						LH0->LH0_CLIENT :=M->LH0_CLIENT
						LH0->LH0_LOJA   :=M->LH0_LOJA
						LH0->LH0_NOME   :=M->LH0_NOME
						LH0->LH0_VEND   :=M->LH0_VEND
						LH0->LH0_DTCAD  :=M->LH0_DTCAD
						LH0->LH0_MKGER  :=M->LH0_MKGER
						LH0->LH0_TOTCUS :=M->LH0_TOTCUS
						LH0->LH0_TOTTAB :=M->LH0_TOTTAB
						LH0->LH0_TOTGER :=M->LH0_TOTGER
						LH0->LH0_MKCUSV :=M->LH0_MKCUSV
						LH0->LH0_MKDIV  :=M->LH0_MKDIV
						LH0->LH0_OBS1   :=M->LH0_OBS1
						LH0->LH0_OBS2   :=M->LH0_OBS2
						LH0->LH0_CONDPA :=M->LH0_CONDPA
						For _nX := 1 To 10
							_cX := 'LH0->LH0_grp'+StrZero(_nX,2)+':=M->LH0_grp'+StrZero(_nX,2)
							_cX := &_cX
							_cX := 'LH0->LH0_mkp'+StrZero(_nX,2)+':=M->LH0_mkp'+StrZero(_nX,2)
							_cX := &_cX
						Next
						MsUnlock()
					Endif
					If !aCols[_nVez,nUsado+1]
						LH1->(reclock('LH1',.t.))
						_fReplLH1(_nVez)
						LH1->(msunlock())
					Endif
				Next
				ConfirmSx8()
			Case cOpcao=="ALTERAR"
				// Primeiro verifica eventuais exclusoes de itens
				LH1->(DbSetOrder(1))
				For _nVez:=1 to Len(aCols)
					If LH1->(dbseek(xfilial("LH1") + M->LH0_COD + T__fValAcols(_nVez,"LH1_ITEM") + T__fValAcols(_nVez,"LH1_PRODUT"),.f.))
						LH1->(reclock(alias(),.f.))
						LH1->(dbdelete())
						LH1->(msunlock())
					Endif
				Next
				For _nVez:=1 to len(aCols)
					If _nVez = 1 .And. LH0->(DbSeek(xfilial("LH0")+M->LH0_COD))
						RecLock('LH0',.F.)
						LH0->LH0_MKGER  :=M->LH0_MKGER
						LH0->LH0_TOTCUS :=M->LH0_TOTCUS
						LH0->LH0_TOTTAB :=M->LH0_TOTTAB
						LH0->LH0_TOTGER :=M->LH0_TOTGER
						LH0->LH0_MKDIV  :=M->LH0_MKDIV
						LH0->LH0_MKCUSV :=M->LH0_MKCUSV
						LH0->LH0_OBS1   :=M->LH0_OBS1
						LH0->LH0_OBS2   :=M->LH0_OBS2
						LH0->LH0_CONDPA :=M->LH0_CONDPA
						For _nX := 1 To 10
							_cX := 'LH0->LH0_grp'+StrZero(_nX,2)+':=M->LH0_grp'+StrZero(_nX,2)
							_cX := &_cX
							_cX := 'LH0->LH0_mkp'+StrZero(_nX,2)+':=M->LH0_mkp'+StrZero(_nX,2)
							_cX := &_cX
						Next
						MsUnlock()
					Endif
					// Verifica se o item ja existe (replace) ou ้ novo (append)
					If !aCols[_nVez,nUsado+1]
						_lNewRec:=!LH1->(dbseek(xfilial("LH1") + M->LH0_COD + T__fValAcols(_nVez,"LH1_ITEM") + T__fValAcols(_nVez,"LH1_PRODUT"),.f.))
						If LH1->(reclock(alias(),_lNewRec))
							_fReplLH1(_nVez)
							LH1->(msunlock())
						Endif
					Endif
				Next
			Case cOpcao=="EXCLUIR".and.msgyesno(STR0056+STR0057) //"Todos os itens da tabela" ## " serao excluidos, confirma ?"
				LH0->(dbsetorder(1))
				LH0->(dbseek(xfilial("LH0")+M->LH0_COD,.f.))
				if LH0->(reclock(alias(),.f.))
					LH0->(dbdelete())
					LH0->(msunlock())
				Endif
				LH1->(Dbsetorder(1))
				LH1->(Dbseek(xfilial("LH1")+M->LH0_COD,.f.))
				Do while LH1->(! Eof()) .AND. LH1->LH1_FILIAL == xfilial("LH1") .AND. LH1->LH1_CODTAB == M->LH0_COD
					if LH1->(reclock(alias(),.f.))
						LH1->(dbdelete())
						LH1->(msunlock())
					endif
					LH1->(dbskip(1))
				Enddo
		EndCase
		LH0->(dbsetorder(_nOrdLH0))
	Endif
	
Endif
SetKey(119 , )
SetKey(120 , )
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณVerTotal  บAutor  ณMicrosiga           บ Data ณ  08/02/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function VerTotal()
Local _nAnt := n

SomaLinha()

@ 000,000 TO 260,195 DIALOG _oDlgTot TITLE STR0058 //"Visualizar Totais"
@ 010,005 say STR0059  SIZE 60,40 //'Custo'
@ 010,050 get M->LH0_TOTCUS picture '@ER 9999,999.99'  SIZE 40,40 when .f.
@ 025,005 say STR0060  SIZE 60,40 //'Negociado'
@ 025,050 get M->LH0_TOTTAB picture '@ER 9999,999.99'  SIZE 40,40 when .f.
@ 055,005 say STR0017 SIZE 60,40 //'Total Venda'
@ 055,050 get M->LH0_TOTGER picture '@ER 9999,999.99'  SIZE 40,40 when .f.
@ 085,005 say STR0061 SIZE 60,40 //'Markup Div.'
@ 085,050 get m->LH0_MKDIV picture '@ER 999'         SIZE 40,40 when .f.
@ 100,005 say STR0018 SIZE 60,40 //'Markup Total'
@ 100,050 get m->LH0_MKCUSV picture '@ER 999'       SIZE 40,40 when .f.
@ 115,037 BmpButton Type 1 Action Close(_oDlgTot)
Activate DIALOG _oDlgTot centered

n := _nAnt

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณImporta   บAutor  ณMicrosiga           บ Data ณ  08/02/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Importa()
Local _nX
DbSelectArea('SUB')
DbSetOrder(1)

If DbSeek(xFilial('SUB')+MV_PAR01)
	_nReg := Recno()
	_aOrca  := {}
	_aGrupo := {}
	While SUB->(! Eof()) .AND. SUB->UB_FILIAL == xFilial('SUB') .And. SUB->UB_NUM == MV_PAR01
		AaDd(_aOrca,{SUB->UB_ITEM,SUB->UB_PRODUTO,SUB->UB_DESCRI,SUB->UB_UM,SUB->UB_VRUNIT,SUB->UB_QUANT,SUB->UB_VLRITEM})
		If aScan(_aGrupo,Posicione('SB1',1,xFilial('SB1')+SUB->UB_PRODUTO,'B1_GRUPO')) = 0 .And. Len(_aGrupo) < 10
			aAdd(_aGrupo,SB1->B1_GRUPO)
		Endif
		DbSkip()
	EndDo
	aSort(_aGrupo)
	ProcRegua(Len(_aOrca))
	DbGoTo(_nReg)
	DbSelectArea('SUA')
	DbSetOrder(1)
	DbSeek(xFilial('SUA')+SUB->UB_NUM)
	_cCliente := SUA->UA_CLIENTE
	_cLoja    := SUA->UA_LOJA
	_cVend    := SUA->UA_VEND
	_cCond    := Iif(!Empty(SUA->UA_CONDPG),SUA->UA_CONDPG,SUA->UA_CONDAF)
	DbSelectArea('LH0')
	RecLock('LH0',.T.)
	LH0->LH0_FILIAL  := xFilial('LH0')
	LH0->LH0_COD     := GetSx8Num('LH0','LH0_COD')
	LH0->LH0_CLIENT := _cCliente
	LH0->LH0_LOJA    := _cLoja
	LH0->LH0_NOME    := Posicione('SA1',1,xFilial('SA1')+_cCliente+_cLoja,'A1_NOME')
	LH0->LH0_VEND    := _cVend
	LH0->LH0_DTCAD   := dDatabase
	LH0->LH0_CONDPA  := _cCond
	//LH0->LH1_CALCFRE := 'N'
	LH0->LH0_NUMORC  := MV_PAR01
	M->LH0_NUMORC    := MV_PAR01 // Utilizado para funcao PegaCusto()
	For _nX := 1 To Len(_aGrupo)
		_cG := 'LH0->LH0_GRP'+StrZero(_nX,2)+':= _aGrupo['+Str(_nX)+']'
		_cG := &_cG
	Next 
	MsUnLock()
	ConfirmSX8()
	m->LH0_TOTCUS := 0
	m->LH0_TOTTAB := 0
	m->LH0_TOTGER := 0
	m->LH0_MKCUSV := 0
	m->LH0_MKDIV  := 0
	For _nX := 1 To Len(_aOrca)
		IncProc(STR0062+_aOrca[_nX,2]+' - '+_aOrca[_nX,3]) //'Processando '
		Posicione('SB1',1,xFilial('SB1')+_aOrca[_nX,2],'')
		Posicione('SB2',1,xFilial('SB2')+_aOrca[_nX,2],'')
		If T_BuscaSalCon(LH0->LH0_CLIENT,SB1->B1_COD) > 0
			_nMix    := T_BuscaSalCon(LH0->LH0_CLIENT,SB1->B1_COD)
			_nDisp   := _nMix
		Else
			_nMix    := T_BuscaSalCon('',SB1->B1_COD)
			_nDisp   := SaldoMov() - _nMix
		Endif
		DbSelectArea('LH7')
		DbSetOrder(1)
		DbSeek(xFilial('LH7')+_aOrca[_nX,2])
		_nPrecoCus := PegaCusto() //(LH7->LH7_PYPRCL* ((100-LH7->LH7_PYFRET)/100))
		If !Empty(LH0->LH0_CONDPA)
			_nPrecoCus := _nPrecoCus * (1+(Posicione('SE4',1,xFilial('SE4')+LH0->LH0_CONDPA,"E4_ACREDCM")/100))
		Endif
		Posicione('SA3',1,xFilial('SA3')+LH0->LH0_VEND,'A3_NOME')		
		Posicione('SU7',3,xFilial('SU7')+SA3->A3_NOME,'U7_POSTO')
		Posicione('SU0',1,xFilial('SU0')+IIf(!Empty(SA1->A1_GRUPOAT),SA1->A1_GRUPOAT,SU7->U7_POSTO),'U0_TABMIN')
		If SU0->U0_TABMIN > 0
			_nMkPol := &('LH7->LH7_MKP'+StrZero(SU0->U0_TABMIN,2))
		Else
			_nMkPol := LH7->LH7_MKP01
		Endif
		DbSelectArea('LH1')
		RecLock('LH1',.T.)
		LH1->LH1_FILIAL :=xFilial('LH1')
		LH1->LH1_ITEM   :=StrZero(_nX,4)
		LH1->LH1_CODTAB :=LH0->LH0_COD
		LH1->LH1_PRODUT :=_aOrca[_nX,2]
		LH1->LH1_DESCRI :=_aOrca[_nX,3]
		LH1->LH1_NOMMAR :=SB1->B1_FABRIC
		LH1->LH1_UM     :=_aOrca[_nX,4]
		LH1->LH1_CUSTO  := _nPrecoCus
		LH1->LH1_MKPOL  := _nMkPol
		LH1->LH1_PRECO  := _aOrca[_nX,5]
		LH1->LH1_MKATU  := ((_aOrca[_nX,5]-_nPrecoCus) / _aOrca[_nX,5]) * 100
		LH1->LH1_QUANT  := _aOrca[_nX,6]
		LH1->LH1_TOTAL  := _aOrca[_nX,7]
		LH1->LH1_ESTOQU := _nDisp
		m->LH0_TOTTAB += LH1->LH1_PRECO
		m->LH0_TOTGER += LH1->LH1_TOTAL
		m->LH0_TOTCUS += (LH1->LH1_QUANT*LH1->LH1_CUSTO)
		MsUnLock()
	Next
	m->LH0_MKCUSV:= ((m->LH0_TOTGER-m->LH0_TOTCUS)/m->LH0_TOTGER)*100
	
	RecLock('LH0',.F.)
	LH0->LH0_TOTCUS  := m->LH0_TOTCUS
	LH0->LH0_TOTTAB  := m->LH0_TOTTAB
	LH0->LH0_TOTGER  := m->LH0_TOTGER
	LH0->LH0_MKDIV   := m->LH0_MKDIV
	LH0->LH0_MKCUSV  := m->LH0_MKCUSV
	MsUnLock()
Else
	MsgStop(STR0063+MV_PAR01+STR0064) //"Orcamento "###" nao Encontrado !"
Endif
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณExporta   บAutor  ณMicrosiga           บ Data ณ  08/02/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP8                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Exporta(_cProxNum)
Local _nPrecoMin := _nPrecoMax := 0

DbSelectArea('LH4')
DbSetOrder(1)
If !LH4->(DbSeek(xFilial('LH4')+_cProxNum))
	RecLock('LH4',.T.)
	LH4->LH4_FILIAL :=xfilial("LH4")
	LH4->LH4_COD    :=_cProxNum
	LH4->LH4_CLIENT :=LH0->LH0_CLIENT
	LH4->LH4_LOJA   :=LH0->LH0_LOJA
	LH4->LH4_NOME   :=LH0->LH0_NOME
	LH4->LH4_CONDPA :=LH0->LH0_CONDPA
	LH4->LH4_INICIO :=MV_PAR01
	LH4->LH4_FINAL  :=MV_PAR02
	If Empty(MV_PAR04)
		LH4->LH4_COMISS:=MV_PAR03
	Endif
	LH4->LH4_NUMORC :=MV_PAR04
	MsUnlock()
Else
	RecLock('LH4',.F.)
	LH4->LH4_CONDPA:=LH0->LH0_CONDPA
	LH4->LH4_INICIO :=MV_PAR01
	LH4->LH4_FINAL  :=MV_PAR02
	If Empty(MV_PAR04)
		LH4->LH4_COMISS:=MV_PAR03
	Else
		LH4->LH4_COMISS:=0
	Endif
	LH4->LH4_NUMORC :=MV_PAR04
	MsUnlock()
Endif

_nCount := 0
DbSelectArea('LH1')
DbSetOrder(1)
DbSeek(xFilial('LH1')+LH0->LH0_COD)
While LH1->(! Eof()) .And. LH1->LH1_FILIAL == xFilial('LH1') .AND. LH1->LH1_CODTAB == LH0->LH0_COD
	++_nCount
	DbSkip()
EndDo

ProcRegua(_nCount)
_lLib := .F.
_nItem := 0
DbSelectArea('LH1')
DbSetOrder(1)
DbSeek(xFilial('LH1')+LH0->LH0_COD)
While LH1->(! Eof()) .And. LH1->LH1_FILIAL == xFilial('LH1') .AND. LH1->LH1_CODTAB == LH0->LH0_COD
	IncProc(STR0062+LH1->LH1_PRODUT+' - '+LH1->LH1_DESCRI) //'Processando '
	DbSelectArea('LH5')
	DbSetOrder(4)
	++_nItem
	If !LH5->(DbSeek(xFilial('LH5')+LH0->LH0_CLIENT+LH1->LH1_PRODUT))
		RecLock('LH5',.T.)
		LH5->LH5_FILIAL  := xFilial('LH5')
		LH5->LH5_CODCON  := _cProxNum
		LH5->LH5_CLIENT  := LH0->LH0_CLIENT
		LH5->LH5_ITEM    := StrZero(_nItem,4)
		LH5->LH5_PRODUT  := LH1->LH1_PRODUT
		LH5->LH5_DESCRI  := Posicione('SB1',1,xFilial('SB1')+LH1->LH1_PRODUT,'B1_DESC')
		cString := cUserName + Save4in2(MsDate()-Ctod("01/01/96"))
		cString := Embaralha(cString,0)
		LH5->LH5_USERGA  := cString
	Else
		RecLock('LH5',.F.)
		cString := cUserName + Save4in2(MsDate()-Ctod("01/01/96"))
		cString := Embaralha(cString,0)
		LH5->LH5_USERGA := cString
	Endif
	LH5->LH5_UM      := LH1->LH1_UM
	LH5->LH5_VALOR   := LH1->LH1_PRECO
	LH5->LH5_CODCLI  := LH1->LH1_CODCLI
	MsUnLock()
	_lLib := .T.
	DbSelectArea('LH1')
	DbSkip()
EndDo
If !Empty(_cProxNum)
	DbSelectArea('LH4')
	ConfirmSX8()
Endif

If !Empty(MV_PAR04)
	DbSelectArea('LH4')
	DbSetOrder(2)
	_aPrecos := {}
	If DbSeek(xFilial('LH4')+LH0->LH0_CLIENT+LH0->LH0_LOJA)
		While LH4->(! Eof()) .And. LH4->LH4_FILIAL == xFilial('LH4') .AND. LH4->LH4_CLIENT == LH0->LH0_CLIENT .AND. LH4->LH4_LOJA == LH0->LH0_LOJA 
			If MV_PAR04 = LH4->LH4_NUMORC
				DbSelectArea('LH5')
				DbSetOrder(2)
				If DbSeek(xFilial('LH5')+LH4->LH4_COD)
					While LH5->(! Eof()) .AND. LH5->LH5_FILIAL == xFilial('LH5') .AND. LH5->LH5_CODCON == LH4->LH4_COD
						AaDd(_aPrecos,{LH5->LH5_PRODUT, LH5->LH5_VALOR})
						DbSkip()
					EndDo
				Endif
				DbSelectArea('SUA')
				DbSetOrder(1)
				If DbSeek(xFilial('SUA')+LH4->LH4_NUMORC)

					DbSelectArea('SU7')
					DbSetOrder(1)
					DbSeek(xFilial('SU7')+SUA->UA_OPERADO)

					DbSelectArea('SU0')
					DbSetOrder(1)
					DbSeek(xFilial('SU0')+IIf(!Empty(SA1->A1_GRUPOAT),SA1->A1_GRUPOAT,SU7->U7_POSTO))
					
					DbSelectArea('SUB')
					DbSetOrder(1)
					If DbSeek(xFilial('SUB')+LH4->LH4_NUMORC)
						_nValTot := 0
						While SUB->(! Eof()) .And. SUB->UB_FILIAL == xFilial('SUB') .AND. SUB->UB_NUM == SUA->UA_NUM
							_nProd := AsCan(_aPrecos,{|x|Alltrim(x[1])=Alltrim(SUB->UB_PRODUTO)})
							If _nProd > 0
								_nPrecoMin := _nPrecoMax := 0
								
								DbSelectArea('SB0')
								DbSetOrder(1)
								If DbSeek(xFilial('SB0')+SUB->UB_PRODUTO)
									_nPrecoMin := 'SB0->B0_PRV'+Alltrim(Str(SU0->U0_TABMIN,2))
									_nPrecoMin := &_nPrecoMin
									_nPrecoMax := 'SB0->B0_PRV'+Alltrim(Str(SU0->U0_TABMAX,2))
									_nPrecoMax := &_nPrecoMax
								Endif  
								
								DbSelectArea('SUB')
								cCalcFrete := SU0->U0_CALAFRE								
								_aPrecoMin := T_PerAcrePre(_nPrecoMin,SUA->UA_CONDAF,SU0->U0_CALAFIN,SU0->U0_CALAFRE)
								_aPrecoMax := T_PerAcrePre(_nPrecoMax,SUA->UA_CONDAF,SU0->U0_CALAFIN,SU0->U0_CALAFRE)
								
								_nDescUM2  := Posicione('LH7',1,xFilial('LH7')+SUB->UB_PRODUTO,'LH7_DU2'+SU0->U0_CODIGO)
								_nDescUM3  := Posicione('LH7',1,xFilial('LH7')+SUB->UB_PRODUTO,'LH7_DU3'+SU0->U0_CODIGO)
								
								_nPrecoMin := _aPrecoMin[1]
								_nAdFinan  := _aPrecoMin[2]
								_nAdFrete  := _aPrecoMin[3]
								_nDescDife := _aPrecoMin[4]
								_nPrecoMax := _aPrecoMax[1]
								
								//_aPrecos    := T_BuscaFaixas(_nPrecoMin,_nPrecoMax,SU0->U0_FAIXAS,(SU0->U0_PEFAI01==0))
								
								RecLock('SUB',.F.)
								SUB->UB_VRUNIT  := _aPrecos[_nProd,2]
								SUB->UB_VLRITEM := _aPrecos[_nProd,2]*SUB->UB_QUANT
								SUB->UB_DESC    := 0
								SUB->UB_VALDESC := 0
								SUB->UB_BASEICM := _aPrecos[_nProd,2]*SUB->UB_QUANT
								SUB->UB_PRCTAB  := _aPrecos[_nProd,2]
								SUB->UB_COMISSA := (_aPrecos[_nProd,2]*SUB->UB_QUANT)*MV_PAR03
								SUB->UB_PERCOM  := MV_PAR03
								SUB->UB_VLRMIN  := _aPrecoMin[1]
								SUB->UB_VLRMAX  := _aPrecoMin[1]
								SUB->UB_ADFRETE := _nAdFinan
								SUB->UB_ADCONDF := _nAdFrete
								SUB->UB_DESCDIF := _nDescDife
								MsUnLock()
							Endif
							_nValTot += SUB->UB_VLRITEM
							DbSkip()
						EndDo
					Endif
					DbSelectArea('SUA')
					RecLock('SUA',.F.)
					SUA->UA_VLRLIQ  := _nValTot
					SUA->UA_VALBRUT := _nValTot
					SUA->UA_VALMERC := _nValTot
					SUA->UA_FINANC  := _nValTot
					MsUnLock()
				Endif
			Endif
			DbSelectArea('LH4')
			DbSkip()
		EndDo
	Endif
Endif
If !_lLib
	MsgStop(STR0065) //'Tabela sem itens verifique !'
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDuplica   บAutor  ณMicrosiga           บ Data ณ  08/02/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Duplica()
Local _nX, _nX2
_aArea := GetArea()
DbSelectArea('SA1')
DbSetOrder(1)
If DbSeek(xFilial('SA1')+MV_PAR01)
	DbSelectArea('LH0')
	_nReg := Recno()
	_cCliente := LH0->LH0_CLIENT
	DbSetOrder(2)
	If DbSeek(xFilial('LH0')+MV_PAR01)
		MsgStop(STR0066) //'Este Cliente jแ possui Tabela Cadastrada!'
		RestArea(_aArea)
		Return(.T.)
	Endif
	DbGoTo(_nReg)
	cLH0_FILIAL  := xFilial('LH0')
	cLH0_COD     := GetSx8Num('LH0','LH0_COD')
	cLH0_CLIENT  := MV_PAR01
	cLH0_LOJA    := '01'
	cLH0_NOME    := Posicione('SA1',1,xFilial('SA1')+MV_PAR01+'01','A1_NOME')
	cLH0_VEND    := LH0->LH0_VEND
	cLH0_DTCAD   := dDatabase
	cLH0_CONDPA  := LH0->LH0_CONDPA
	DbSelectArea('SX3')
	DbSeek('LH1')
	_cCampos := ''
	_aSx3    := {}
	While !Eof() .And. SX3->X3_ARQUIVO = 'LH1'
		If SX3->X3_CONTEXT = 'V'
			DbSkip()
			Loop
		Endif
		_cCampos += SX3->X3_CAMPO+','
		AaDd(_aSx3,SX3->X3_CAMPO)
		DbSkip()
	EndDo
	_cCampos := '{'+SubStr(_cCampos,1,Len(_cCampos)-1)+'}'
	DbSelectArea('LH1')
	DbSetOrder(1)
	DbSeek(xFilial('LH1')+LH0->LH0_COD)
	_aItens := {}
	While LH1->(! Eof()) .AND. LH1->LH1_FILIAL == xFilial('LH1') .And. LH1->LH1_CODTAB == LH0->LH0_COD 
		AaDd(_aItens,&_cCampos)
		DbSkip()
	EndDo
	ProcRegua(Len(_aItens))
	DbSelectArea('LH0')
	RecLock('LH0',.T.)
	LH0_FILIAL  := cLH0_FILIAL
	LH0_COD     := cLH0_COD
	LH0_CLIENT  := cLH0_CLIENT
	LH0_LOJA    := cLH0_LOJA
	LH0_NOME    := cLH0_NOME
	LH0_VEND    := cLH0_VEND
	LH0_DTCAD   := cLH0_DTCAD
	LH0_CONDPA  := cLH0_CONDPA
	MsUnLock()
	ConfirmSX8()
	
	m->LH0_TOTCUS := 0
	m->LH0_TOTTAB := 0
	m->LH0_TOTGER := 0
	m->LH0_MKCUSV := 0
	m->LH0_MKDIV  := 0
	
	DbSelectArea('LH1')
	For _nX := 1 To Len(_aItens)
		IncProc(STR0062+_aItens[_nX,2]+' - '+_aItens[_nX,3]) //'Processando '
		If MV_PAR02 = 1
			DbSelectArea('LH7')
			DbSetOrder(1)
			DbSeek(xFilial('LH7')+_aItens[_nX,AsCan(_aSx3,'LH1_PRODUT')])
		Endif
		RecLock('LH1',.T.)
		For _nX2 := 1 To Len(_aSx3)
			_cX := _aSx3[_nX2]
			If (!Alltrim(_cX) $ 'LH1_CODTAB')
				LH1->(&_cX) := _aItens[_nX,_nX2]
			ElseIf Alltrim(_cX) = 'LH1_CODTAB'
				LH1->LH1_CODTAB := cLH0_COD
			Endif
		Next
		If MV_PAR02 = 1
			_cEstOri  := Posicione('SA1',1,xFilial('SA1')+_cCliente,'A1_EST')
			_nAliqOri := Iif(_cEstOri=SuperGetMv('MV_ESTADO'),SuperGetMv('MV_ICMPAD'),;
			Iif(_cEstOri$SuperGetMv('MV_NORTE'),0.93,0.88))
			If Posicione('SA1',1,xFilial('SA1')+cLH0_CLIENT,'A1_EST') $ GetMv('MV_NORTE')
				_nAliq := 0.93
			ElseIf SA1->A1_EST <> SuperGetMv('MV_ESTADO')
				_nAliq := 0.88
			Else
				_nAliq := 0.82
			Endif
			If _cEstOri <> SA1->A1_EST
				LH1->LH1_PRECO  := (_aItens[_nX,AsCan(_aSx3,'LH1_PRECO')]*(100-_nAliqOri)/100)/_nAliq
				M->LH0_NUMORC  := ''
				_nPreCus := PegaCusto() //(LH7->LH7_PYPRCL * ((100-LH7->LH7_PYFRET)/100))
				If !Empty(M->LH0_CONDPA)
					_nPreCus := _nPreCus * (1+(Posicione('SE4',1,xFilial('SE4')+LH0->LH0_CONDPA,"E4_ACREDCM")/100))
				Endif
				LH1->LH1_MKATU  := ((LH1->LH1_PRECO-_nPreCus) / LH1->LH1_PRECO) * 100
				LH1->LH1_QUANT  := _aItens[_nX,AsCan(_aSx3,'LH1_QUANT')]
				LH1->LH1_TOTAL  := LH1->LH1_PRECO * _aItens[_nX,AsCan(_aSx3,'LH1_QUANT')]
			Endif
		Endif
		m->LH0_TOTTAB += LH1->LH1_PRECO
		m->LH0_TOTGER += LH1->LH1_TOTAL
		m->LH0_TOTCUS+= (LH1->LH1_QUANT*LH1->LH1_CUSTO)
		MsUnLock()
	Next
	m->LH0_MKCUSV:= ((m->LH0_TOTGER-m->LH0_TOTCUS)/m->LH0_TOTGER)*100
	
	RecLock('LH0',.F.)
	LH0->LH0_TOTCUS  := m->LH0_TOTCUS
	LH0->LH0_TOTTAB  := m->LH0_TOTTAB
	LH0->LH0_TOTGER  := m->LH0_TOTGER
	LH0->LH0_MKDIV   := m->LH0_MKDIV
	LH0->LH0_MKCUSV  := m->LH0_MKCUSV
	MsUnLock()
	
	MsgBox(STR0067+Chr(13)+; //"Duplicacao Realizada com Sucesso !"
	STR0068+LH0->LH0_COD,STR0069,"INFO") //"Tabela numero:"###"Duplicacao"
Else
	MsgStop(STR0070+MV_PAR01+STR0064) //"Cliente "###" nao Encontrado !"
Endif
RestArea(_aArea)
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCria_TLH1 บAutor  ณMicrosiga           บ Data ณ  08/02/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP8                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static FUNCTION Cria_TLH1()
Local _nX
DbSelectArea('SX3')
DbSetOrder(1)
AADD(aFields,{"LH1_OK"     ,"C",02,0})
For _nX := 1 To Len(_aArqSel)
	DbSeek(_aArqSel[_nX])
	While !Eof() .And. X3_ARQUIVO = _aArqSel[_nX]
		If ALLTRIM(X3_CAMPO) $ _cCampos
			AADD(aFields,{X3_CAMPO,X3_TIPO,X3_TAMANHO,X3_DECIMAL})
		Endif
		DbSkip()
	EndDo
Next
cArq:=Criatrab(aFields,.T.)
DBUSEAREA(.t.,,cArq,"TLH1")
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMonta_TLH1บAutor  ณMicrosiga           บ Data ณ  08/02/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Monta_TLH1()
Local _nX
_nCount := 0
For _nX := 1 To 2
	If _nX = 1
		cQueryCad := "SELECT Count(*) AS TOTAL FROM "+_cArqSel2+" WHERE "
	Else
		cQueryCad := "SELECT "
		cQueryCad += _cCampos
		cQueryCad += " FROM "+_cArqSel2+" WHERE "
	Endif
	cQueryCad += RetSqlName("LH1")+".D_E_L_E_T_ <> '*' AND "
	cQueryCad += RetSqlName("SB1")+".D_E_L_E_T_ <> '*' AND "
	cQueryCad += "LH1_PRODUT = B1_COD AND "
	cQueryCad += "LH1_FILIAL = '"+xFilial("LH1")+"' AND "
	cQueryCad += "B1_FILIAL = '"+xFilial("SB1")+"' AND "
	cQueryCad += "LH1_CODTAB = '"+LH0->LH0_COD+"' "
	If _nX = 2
		cQueryCad += "ORDER BY LH1_CODTAB, LH1_ITEM, LH1_PRODUT"
	Endif
	
	TCQUERY cQueryCad NEW ALIAS "CAD"
	If _nX = 1
		_nCount := CAD->TOTAL
		DbCloseArea()
	Endif
Next

Dbselectarea("CAD")

ProcRegua(_nCount)

While CAD->(!EOF())
	IncProc()
	RecLock("TLH1",.T.)
	For _nX := 1 To Len(aFields)
		If aFields[_nX,1] <> 'LH1_OK'
			If aFields[_nX,2] = 'C'
				_cX := 'TLH1->'+aFields[_nX,1]+' := Alltrim(CAD->'+aFields[_nX,1]+')'
			Else
				_cX := 'TLH1->'+aFields[_nX,1]+' := CAD->'+aFields[_nX,1]
			Endif
			_cX := &_cX
		Endif
	Next
	If AsCan(_aMarcas,TLH1->LH1_NOMMAR) = 0
		AaDd(_aMarcas,TLH1->LH1_NOMMAR)
	Endif
	TLH1->LH1_OK := ThisMark()
	MsUnLock()
	CAD->(dBSkip())
EndDo
AaDd(_aMarcas,'')
ASort(_aMarcas)
Dbselectarea("CAD")
DbCloseArea()
Dbselectarea("TLH1")
DbGoTop()

_cIndex:=Criatrab(Nil,.F.)
_cChave:="LH1_ITEM+LH1_PRODUT+B1_DESC"
Indregua("TLH1",_cIndex,_cChave,,,STR0071) //"Ordenando registros selecionados..."
DbSetIndex(_cIndex+ordbagext())

SysRefresh()
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณConfirma   บAutor  ณMicrosiga           บ Data ณ  08/02/05   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                             บฑฑ
ฑฑบ          ณ                                                             บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                          บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static FUNCTION Confirma()
If !MsgYesNo(STR0072) //'Confirma o reajuste dos itens marcados ?'
	Return(.T.)
Endif
Processa({||ConfirmaLed()})
Close(oDlgRea)
Return(.T.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณConfirmaLedบAutor  ณMicrosiga           บ Data ณ  08/02/05   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                             บฑฑ
ฑฑบ          ณ                                                             บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                          บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static FUNCTION ConfirmaLed()

_lLib := .F.
_nAcrescimo := Iif(!Empty(_cAcrescimo),Val(_cAcrescimo),0)
_nDesconto  := Iif(!Empty(_cDesconto),Val(_cDesconto),0)
_nMarkup    := Iif(!Empty(_cMarkup),Val(_cMarkup),0)
DbSelectArea('TLH1')
ProcRegua(RecCount())
DbGoTop()
While !Eof()
	If TLH1->LH1_OK == _cMark
		IncProc(STR0073+TLH1->LH1_PRODUT) //'Atualizando...'
		Posicione('SB1',1,xFilial('SB1')+TLH1->LH1_PRODUT,'')
		Posicione('LH7',1,xFilial('LH7')+TLH1->LH1_PRODUT,'')
		_nQtdEmb := IIf(TLH1->LH1_UM == SB1->B1_UM, 1,;
		                IIf(TLH1->LH1_UM == SB1->B1_SEGUM, SB1->B1_CONV,;
		                    IIf(TLH1->LH1_UM == SB1->B1_UM3, SB1->B1_UM3FAT,;
		                        IIf(TLH1->LH1_UM == SB1->B1_UM4, SB1->B1_UM4FAT, 1))))
		DbSelectArea('LH1')
		DbSetOrder(1)
		If DbSeek(xFilial('LH1')+LH0->LH0_COD+TLH1->LH1_ITEM+TLH1->LH1_PRODUT)
			RecLock('LH1',.F.)
			M->LH0_NUMORC  := LH0->LH0_NUMORC
			_nPreCus      := PegaCusto() * _nQtdEmb
			If !Empty(LH0->LH0_CONDPA)
				_nPreCus := _nPreCus * (1+(Posicione('SE4',1,xFilial('SE4')+LH0->LH0_CONDPA,"E4_ACREDCM")/100))
			Endif
			LH1->LH1_CUSTO := _nPreCus
			If _nAcrescimo > 0
				LH1->LH1_PRECO := LH1->LH1_PRECO * (1+(_nAcrescimo/100))
				LH1->LH1_MKATU := ((LH1->LH1_PRECO-_nPreCus) / LH1->LH1_PRECO) * 100
			Endif
			If _nDesconto > 0
				LH1->LH1_PRECO := LH1->LH1_PRECO * ((100-_nDesconto)/100)
				LH1->LH1_MKATU := ((LH1->LH1_PRECO-_nPreCus) / LH1->LH1_PRECO) * 100
			Endif
			If _nMarkup > 0
				LH1->LH1_MKATU := _nMarkup
			Endif
			LH1->LH1_PRECO := (_nPreCus / ((100-LH1->LH1_MKATU)/100)) * _nQtdEmb
			LH1->LH1_TOTAL := LH1->LH1_PRECO * LH1->LH1_QUANT
			MsUnLock()
			_lLib := .T.
		Endif
		DbSelectArea('TLH1')
	Else
		IncProc(STR0074) //'Pesquisando ...'
	EndIf
	DbSkip()
EndDo
If _lLib
	MsgBox(STR0075,STR0076,'INFO') //'Reajustes efetuadas com sucesso !'###'Reajustes'
	//Close(oDlgRea)
Else
	MsgStop(STR0077) //'Nenhum item marcado para reajuste !'
Endif
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMarca     บAutor  ณMicrosiga           บ Data ณ  08/02/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Marcar()
DbSelectArea('TLH1')
RecLock('TLH1',.F.)
TLH1->LH1_OK := Iif(Empty(TLH1->LH1_OK),_cMark,ThisMark())
MsUnlock()
SysRefresh()
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMarcaTudo บAutor  ณMicrosiga           บ Data ณ  08/02/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MarcaTudo()
DbSelectArea('TLH1')
_nRec := Recno()
While !Eof()
	RecLock('TLH1',.F.)
	If !Empty(_cMarca)
		If TLH1->LH1_NOMMAR = _cMarca
			TLH1->LH1_OK := Iif(TLH1->LH1_OK==_cMark,ThisMark(),_cMark)
		Endif
	Else
		TLH1->LH1_OK := Iif(TLH1->LH1_OK==_cMark,ThisMark(),_cMark)
	Endif
	MsUnlock()
	DbSkip()
EndDo
DbGoTo(_nRec)
SysRefresh()
DlgRefresh(oDlgRea)
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ_fReplLH1 บAutor  ณMicrosiga           บ Data ณ  08/02/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static function _fReplLH1(_nVez)

LH1->LH1_FILIAL :=xFilial('LH1')
LH1->LH1_CODTAB :=M->LH0_COD
LH1->LH1_ITEM   :=T__fValAcols(_nVez,"LH1_ITEM")
LH1->LH1_PRODUT :=T__fValAcols(_nVez,"LH1_PRODUT")
LH1->LH1_DESCRI :=T__fValAcols(_nVez,"LH1_DESCRI")
LH1->LH1_NOMMAR :=T__fValAcols(_nVez,"LH1_NOMMAR")
LH1->LH1_UM     :=T__fValAcols(_nVez,"LH1_UM")
LH1->LH1_CUSTO  :=T__fValAcols(_nVez,"LH1_CUSTO")
LH1->LH1_MKPOL  :=T__fValAcols(_nVez,"LH1_MKPOL")
LH1->LH1_MKATU  :=T__fValAcols(_nVez,"LH1_MKATU")
LH1->LH1_PRECO  :=T__fValAcols(_nVez,"LH1_PRECO")
LH1->LH1_CODCLI :=T__fValAcols(_nVez,"LH1_CODCLI")
LH1->LH1_DESCPR :=T__fValAcols(_nVez,"LH1_DESCPR")
LH1->LH1_QUANT  :=T__fValAcols(_nVez,"LH1_QUANT")
LH1->LH1_TOTAL  :=T__fValAcols(_nVez,"LH1_TOTAL")
LH1->LH1_ESTOQU :=T__fValAcols(_nVez,"LH1_ESTOQU")

return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRptdetail บAutor  ณMicrosiga           บ Data ณ  08/02/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static function Rptdetail

LH0->(dbsetorder(1))

if !LH0->(dbseek(xfilial("LH0")+MV_PAR01,.f.))
	msgbox(STR0078+MV_PAR01+STR0079) //"Tabela ["###"] nao encontrada..."
endif

cabec1:=LH0->(STR0080+LH0_COD+STR0081+LH0_CLIENT+" - "+LH0_NOME) //"PROPOSTA: "###" CLIENTE: "
If MV_PAR04 = 1
	_cCab1:=STR0082 //"Item;Descricao do Produto;Cod.Nosso;Cod.Cliente;UM;Preco;Marca;Quantidade;Total"
	_cCab2:=""
Else
	_cCab1:=STR0083 //"Item Descricao do Produto                     Cod.Cliente           UM     Preco"
	_cCab2:=STR0084 //"     Marca                             Cod.Nosso         Quantidade        Total"
Endif
//Item Descricao do Produto                     Cod.Cliente           UM     Preco
//     Marca                             Cod.Nosso         Quantidade        Total
//999  1234567890123456789012345678901234567890 123456789012345678901 12 99,999.99
//     12345678901234567890              123456789012345       999999    99,999.99
//                                                            TOTAL ->
//01234567890123456789012345678901234567890123456789012345678901234567890123456789
//          1         2         3         4         5         6         7
If MV_PAR04 = 1
	_cDet1 := "LH1->(LH1_ITEM+';'+"+;
	          "SubStr(Posicione('SB1',1,xFilial('SB1')+LH1_PRODUT,'B1_DESC'),1,40)+';'+"+;
	          "SubStr(LH1_PRODUT,1,9)+';'+"+;
	          "Iif(Empty(LH1_CODCLI),Space(11),SubStr(LH1_CODCLI,1,11))+';'+"+;
	          "LH1_UM+';'+"+;
	          "tran(LH1_PRECO,'@ER 99,999.99')+';'+"+;
	          "LH1_NOMMAR+';'+"+;
	          "tran(LH1_QUANT,'@ER 999999')+';'+"+;
	          "tran(LH1_TOTAL,'@ER 99,999.99'))"
	_cDet2 := ""
Else
	_cDet1 := "LH1->(LH1_ITEM+' '+"+;
	          "SubStr(Posicione('SB1',1,xFilial('SB1')+LH1_PRODUT,'B1_DESC'),1,40)+' '+"+;
	          "Iif(Empty(LH1_CODCLI),Space(21),SubStr(LH1_CODCLI,1,21))+' '+"+;
	          "LH1_UM+' '+"+;
	          "tran(LH1_PRECO,'@ER 99,999.99'))"
	_cDet2 := "Space(5)+LH1->LH1_NOMMAR+Space(14)+LH1->LH1_PRODUT+Space(7)+Iif(LH1->LH1_QUANT>1,tran(LH1->LH1_QUANT,'@ER 999999')+Space(2)+tran(LH1->LH1_TOTAL,'@ER 9999,999.99'),'')"
Endif

SetDefault(aReturn,cString)
nTipo := 4
setprc(0,0)
setregua(RecCount())
If MV_PAR03 = 1
	LH1->(dbsetorder(3))
ElseIf MV_PAR03 = 2
	LH1->(dbsetorder(2))
ElseIf MV_PAR03 = 3
	LH1->(dbsetorder(5))
ElseIf MV_PAR03 = 4
	LH1->(dbsetorder(1))
ElseIf MV_PAR03 = 5
	LH1->(dbsetorder(4))
Endif
LH1->(dbseek(xfilial("LH1")+LH0->LH0_COD,.f.))
If MV_PAR04 = 1
	_nLin := 0
	@ _nLin   , 00 PSAY Titulo
	++_nLin
	@ _nLin   , 00 PSAY Cabec1
	++_nLin
	@ _nLin   , 00 PSAY _cCab1
	++_nLin
Endif
_nTotal := 0
do while LH1->(!eof().and.LH1_FILIAL+LH1_CODTAB=xfilial('LH0')+LH0->LH0_COD)
	incregua()
	if _nLin>=_nLimiteLin .And. MV_PAR04 <> 1
		Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,18)
		_nLin := li
		@ _nLin   , 00 PSAY _cCab1
		@ _nLin+=1, 00 PSAY _cCab2
		@ _nLin+=1, 00 PSAY Replicate('*',80)
		++_nLin
	endif
	@ ++_nLin,00 PSAY &_cDet1
	If MV_PAR04 <> 1
		@ ++_nLin,00 PSAY &_cDet2
	Endif
	_nTotal += LH1->LH1_TOTAL
	LH1->(dbskip(1))
enddo
If MV_PAR04 <> 1
	@ _nLin+=2,56 PSAY 'TOTAL -> '
	@   _nLin ,68 PSAY tran(_nTotal,'@ER 9,999,999.99')
	If !Empty(LH0->LH0_CONDPA)
		@ _nLin+=2,00 PSAY STR0085+Posicione('SE4',1,xFilial('SE4')+LH0->LH0_CONDPA,'E4_DESCRI') //'Condicao de Pagamento:'
	Endif
	@ _nLin+=2,00 PSAY LH0->LH0_OBS1
	@ _nLin+=1,00 PSAY LH0->LH0_OBS2
	Roda(0,"","P")
Endif
If aReturn[5] == 1
	Set Printer To
	Commit
	ourspool(wnrel)
Endif
MS_FLUSH()

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSomaLinha บAutor  ณMicrosiga           บ Data ณ  08/02/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function SomaLinha()
Local _nVez
M->LH0_TOTCUS := 0
M->LH0_TOTTAB := 0
M->LH0_TOTGER := 0
M->LH0_TOTCUV := 0
M->LH0_MKCUSV := 0

_nPosCusto  := AsCan(aHeader,{|x|Alltrim(Upper(x[2]))=='LH1_CUSTO'})
_nPosPreco  := AsCan(aHeader,{|x|Alltrim(Upper(x[2]))=='LH1_PRECO'})
_nPosTotal  := AsCan(aHeader,{|x|Alltrim(Upper(x[2]))=='LH1_TOTAL'})
_nPosQuant  := AsCan(aHeader,{|x|Alltrim(Upper(x[2]))=='LH1_QUANT'})
_nPosMkatu  := AsCan(aHeader,{|x|Alltrim(Upper(x[2]))=='LH1_MKATU'})

for _nVez:=1 to len(aCols)
	If !aCols[_nVez,nUsado+1]
		M->LH0_TOTTAB += aCols[_nVez,_nPosPreco]
		M->LH0_TOTCUV += aCols[_nVez,_nPosCusto]
		M->LH0_TOTGER += aCols[_nVez,_nPosTotal]
		M->LH0_TOTCUS += (aCols[_nVez,_nPosQuant]*aCols[_nVez,_nPosCusto])
	Endif
next
M->LH0_MKDIV  := ((M->LH0_TOTTAB-M->LH0_TOTCUV)/M->LH0_TOTTAB)*100
M->LH0_MKCUSV:= ((M->LH0_TOTGER-M->LH0_TOTCUS)/M->LH0_TOTGER)*100

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAtuPreLH1 บAutor  ณMicrosiga           บ Data ณ  08/02/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Template Function AtuPreLH1(_nTipo)
Local _nX2, _nX
_aArea := GetArea()
_nPosCusto  := AsCan(aHeader,{|x|Alltrim(Upper(x[2]))=='LH1_CUSTO'})
_nPosPreco  := AsCan(aHeader,{|x|Alltrim(Upper(x[2]))=='LH1_PRECO'})
_nPosMkPol  := AsCan(aHeader,{|x|Alltrim(Upper(x[2]))=='LH1_MKPOL'})
_nPosMkAtu  := AsCan(aHeader,{|x|Alltrim(Upper(x[2]))=='LH1_MKATU'})
_nPosQuant  := AsCan(aHeader,{|x|Alltrim(Upper(x[2]))=='LH1_QUANT'})
_nPosTotal  := AsCan(aHeader,{|x|Alltrim(Upper(x[2]))=='LH1_TOTAL'})

//If M->LH1_CALCFRE = 'S' .Or. M->LH1_CALCFRE = 'N'
If cCalcFrete = 'S' .Or. cCalcFrete = 'N'
	_cEst := Posicione('SA1',1,xFilial('SA1')+M->LH0_CLIENT+M->LH0_LOJA,'A1_EST')
	_cMun := SA1->A1_MUN
Endif

For _nX := 1 To Len(aCols)
	Posicione('SB1',1,xFilial('SB1')+aCols[_nX,2],'')
	Posicione('LH7',1,xFilial('LH7')+aCols[_nX,2],'')
	Posicione('SU7',3,xFilial('SU7')+M->LH0_NOMEVE,'U7_POSTO')
	Posicione('SU0',1,xFilial('SU0')+IIf(!Empty(SA1->A1_GRUPOAT),SA1->A1_GRUPOAT,SU7->U7_POSTO),'U0_TABMIN')
	
	_cUnid := Iif(Empty(aCols[_nX,4]),SB1->B1_UM,aCols[_nX,4])
	_nQtdEmb := IiF(_cUnid=SB1->B1_UM,1,;
	IiF(_cUnid=SB1->B1_SEGUM,SB1->B1_CONV,;
	IiF(_cUnid=SB1->B1_UM3,SB1->B1_UM3TO1,;
	IiF(_cUnid=SB1->B1_UM4,SB1->B1_UM4TO1,1))))
	aCols[_nX,_nPosCusto] := PegaCusto() * _nQtdEmb //(LH7->LH7_PYPRCL* ((100-LH7->LH7_PYFRET)/100)) * _nQtdEmb
	aCols[_nX,_nPosPreco] := aCols[_nX,_nPosCusto] / ((100-aCols[_nX,_nPosMkAtu])/100)
	aCols[_nX,_nPosMkAtu] := ((aCols[_nX,_nPosPreco] - aCols[_nX,_nPosCusto]) / aCols[_nX,_nPosPreco]) * 100
	aCols[_nX,_nPosTotal] := aCols[_nX,_nPosPreco] * aCols[_nX,_nPosQuant]
	If !Empty(M->LH0_CONDPA)
		aCols[_nX,_nPosCusto] := LH7->LH7_PRC * _nQtdEmb
		aCols[_nX,_nPosCusto] := aCols[_nX,_nPosCusto] * (1+(Posicione('SE4',1,xFilial('SE4')+M->LH0_CONDPA,"E4_ACREDCM")/100))
		If SU0->U0_TABMIN > 0
			aCols[_nX,_nPosMkPol] := &('LH7->LH7_MKP'+StrZero(SU0->U0_TABMIN,2))
		Else
			aCols[_nX,_nPosMkPol] := LH7->LH7_MKP01
		Endif
		_aMarkup := {}
		For _nX2 := 1 To 10
			_cG := "M->LH0_GRP"+StrZero(_nX2,2)
			_cM := "M->LH0_MKP"+StrZero(_nX2,2)
			AaDd(_aMarkup,{&_cG,&_cM})
		Next
		aCols[_nX,_nPosMkAtu] := ((aCols[_nX,_nPosPreco]-aCols[_nX,_nPosCusto]) / aCols[_nX,_nPosPreco]) * 100
	Endif
Next
//oGetDados := CallMod2Obj()
oGetDados:Refresh()
oGetDados:oBrowse:Refresh()
RestArea(_aArea)
Return(Iif(_nTipo=1,M->LH0_CONDPA,M->LH1_CALCFRE))
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o	 ณModelo3	  ณ Autor ณ Wilson 			    ณ Data ณ 17/03/97 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณEnchoice e GetDados										  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณlRet:=Modelo3(cTitulo,cAlias1,cAlias2,aMyEncho,cLinOk, 	  ณฑฑ
ฑฑณ			 ณ cTudoOk,nOpcE,nOpcG,cFieldOk,lVirtual,nLinhas,aAltEnchoice)ณฑฑ
ฑฑณ			 ณlRet=Retorno .T. Confirma / .F. Abandona					  ณฑฑ
ฑฑณ			 ณcTitulo=Titulo da Janela 									  ณฑฑ
ฑฑณ			 ณcAlias1=Alias da Enchoice							 		  ณฑฑ
ฑฑณ			 ณcAlias2=Alias da GetDados									  ณฑฑ
ฑฑณ			 ณaMyEncho=Array com campos da Enchoice		 			      ณฑฑ
ฑฑณ			 ณcLinOk=LinOk 												  ณฑฑ
ฑฑณ			 ณcTudOk=TudOk 												  ณฑฑ
ฑฑณ			 ณnOpcE=nOpc da Enchoice									  ณฑฑ
ฑฑณ			 ณnOpcG=nOpc da GetDados									  ณฑฑ
ฑฑณ			 ณcFieldOk=validacao para todos os campos da GetDados 		  ณฑฑ
ฑฑณ			 ณlVirtual=Permite visualizar campos virtuais na enchoice	  ณฑฑ
ฑฑณ			 ณnLinhas=Numero Maximo de linhas na getdados				  ณฑฑ
ฑฑณ			 ณaAltEnchoice=Array com campos da Enchoice Alteraveis		  ณฑฑ
ฑฑณ			 ณnFreeze=Congelamento das colunas.                           ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso		 ณRdMake 													  ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function Modelo3Meu(cTitulo,cAlias1,cAlias2,aMyEncho,cLinOk,cTudoOk,;
							nOpcE,nOpcG,cFieldOk,lVirtual,nLinhas,aAltEnchoice,;
							nFreeze,aButtons,aCordW,nSizeHeader)
							
Local	lRet

Local	cSaveMenuh  

Local	nOpca	:=	0
Local	nReg	:=	(cAlias1)->(Recno())
Local	nDlgHeight
Local	nGDHeight

Local	oDlg
Local	oEnchoice

Private Altera:=.t.,Inclui:=.t.,lRefresh:=.t.,aTELA:=Array(0,0),aGets:=Array(0),;
bCampo:={|nCPO|Field(nCPO)},nPosAnt:=9999,nColAnt:=9999
Private cSavScrVT,cSavScrVP,cSavScrHT,cSavScrHP,CurLen,nPosAtu:=0

nOpcE	:=	If(nOpcE==Nil,3,nOpcE)
nOpcG	:=	If(nOpcG==Nil,3,nOpcG)
lVirtual:=	Iif(lVirtual==Nil,.F.,lVirtual)
nLinhas	:=	Iif(nLinhas==Nil,99,nLinhas)

If SetMDIChild()
	oMainWnd:ReadClientCoors()
	nDlgHeight := 500
	nGDHeight  := oMainWnd:nBottom
Else
	nDlgHeight := 420
	nGDHeight  := 70
EndIf

DEFINE MSDIALOG oDlg TITLE cTitulo From aSizeAut[7],0 to aSizeAut[6],aSizeAut[5] Pixel of oMainWnd //aCordW[1],aCordW[2] to aCordW[3],aCordW[4] 

oEnchoice := Msmget():New(cAlias1,nReg,nOpcE,,,,aMyEncho,aPosObj[1],aAltEnchoice,3,,,,,,lVirtual,,,,,,,,.T.)

oGetDados := MsGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpcG,cLinOk,cTudoOk,"",.T.,,nFreeze,,nLinhas,cFieldOk)

ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,{||nOpca:=1,If(oGetDados:TudoOk(),If(!obrigatorio(aGets,aTela),nOpca := 0,oDlg:End()),nOpca := 0)},{||oDlg:End()},,aButtons)) //,;

lRet	:=	(nOpca==1)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPegaCusto บAutor  ณMicrosiga           บ Data ณ  08/02/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PegaCusto()

M->LH0_DTCAD   := IIF(Type('M->LH0_DTCAD')<>'U',M->LH0_DTCAD,IIF(!Empty(LH0->LH0_DTCAD),LH0->LH0_DTCAD,Date()))
M->LH0_CONDPA := IIF(Type('M->LH0_CONDPA')<>'U',M->LH0_CONDPA,IIF(!Empty(LH0->LH0_CONDPA),LH0->LH0_CONDPA,GetMv('MV_CONDPAD')))
_nCusto := IIF(ExistBlock("TCOMA05PC"),ExecBlock("TCOMA05PC"),LH7->LH7_PRC)
Return	_nCusto

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ_fValAcolsบAutor  ณMicrosiga           บ Data ณ  08/02/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Template Function _fValAcols(_nItem,_cCampo)
local _xValor
_cCampo:=alltrim(upper(_cCampo))
// Verifica se nao ้ ele mesmo que estแ sendo digitado no momento
if _cCampo$upper(readvar())
	_xValor:=readVar()
	_xValor:=&(_xValor)
else
	_nPosic:=aScan(aHeader,{|x|Alltrim(upper(x[2])) == alltrim(upper(_cCampo))})
	if _nPosic==0
		msgbox("T__fValAcols: Campo "+_cCampo+STR0090) //" nao localizado no acols atual"
	else
		_xValor  := aCols[_nItem,_nPosic]
	endif
endif
return _xValor