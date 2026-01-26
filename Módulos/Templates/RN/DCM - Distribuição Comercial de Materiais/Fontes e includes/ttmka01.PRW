#INCLUDE "ttmka01.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "TOPCONN.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTTMKA01   บ Autor ณ EWERTON CARLOS TOM บ Data ณ  03/12/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ CONSULTA PRECO                                             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5 IDE                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Template Function TTMKA01(cProd)
Local _nX
Private _aArea    := GetArea()
Private _aAreaSX5 := SX5->(GetArea())
Private _aAreaSB1 := SB1->(GetArea())
Private _nPrecoMiA:= _nPrecoMi := _nPrecoMin := _nPrecoMax := _nValFaixa := 0
Private _nAdFinan := _nAdFrete := _nDescDife := 0
Private _aPrecos  := _aPrecoMin:= _aPrecoMax := _aPrecosPro := {}
Private oPreco
Private M->UA_CONDAF := IIf(Type("M->UA_CONDAF")<>"U",M->UA_CONDAF,GetMV("MV_CONDPAD"))
Private _cCodPro  := ''
Private _cSit     := ''
Private _cDesPro  := ''
Private _cArqTrab := ''
Private _nCol     := _nCol2 := 0
Private _nValRet  := 0
Private _nDescUM2 := _nDescUM3 := 0

If Type('M->UA_CLIENTE') <> 'U'
	If T_BuscaValCon(M->UA_CLIENTE,cProd)
		If (!Empty(LH4->LH4_NUMORC) .And. LH4->LH4_NUMORC = M->UA_NUM) .Or. Empty(LH4->LH4_NUMORC) 
			RestArea(_aArea)
			If Funname(0) = 'TMKA271'
				aCols[n,AsCan(aHeader,{|x|Alltrim(x[2])=='UB_VRUNIT'})] := LH5->LH5_VALOR
				aCols[n,AsCan(aHeader,{|x|Alltrim(x[2])=='UB_PRCTAB'})] := LH5->LH5_VALOR
				aCols[n,AsCan(aHeader,{|x|Alltrim(x[2])=='UB_VLRITEM'})]:= LH5->LH5_VALOR
				aCols[n,AsCan(aHeader,{|x|Alltrim(x[2])=='UB_BASEICM'})]:= LH5->LH5_VALOR
				aCols[n,AsCan(aHeader,{|x|Alltrim(x[2])=='UB_PERCOM'})] := LH4->LH4_COMISS
				aCols[n,AsCan(aHeader,{|x|Alltrim(x[2])=='UB_COMISSA'})]:= (LH5->LH5_VALOR*LH4->LH4_COMISS)/100
				aCols[n,aScan(aHeader,{|x|Alltrim(x[2])=='UB_VLRMIN'})] := LH5->LH5_VALOR
				aCols[n,aScan(aHeader,{|x|Alltrim(x[2])=='UB_VLRMAX'})] := LH5->LH5_VALOR
				Return(LH5->LH5_VALOR)
			Else
				//MsgInfo("Preco Negociado ou Preco de Contrato.","Informacao","INFO") 
				MsgInfo(STR0001,STR0002) //"Preco Negociado ou Preco de Contrato."###"Informacao"
			EndIf
		EndIf
	EndIf
EndIf

_lSai    := .T.
_nValor  := 0
_cCodPro := Posicione('SB1',1,xFilial('SB1')+cProd,'B1_COD')
_cSit    := SB1->B1_SITPROD
_cDesPro := SB1->B1_DESC
_nIcms   := SB1->B1_PICM

If funname(0) <> 'TMKA271'
	DbSelectArea('SU7')
	DbSetOrder(3)
	If !DbSeek(xFilial('SU7')+ cUserName)
		RestArea(_aAreaRest)
		MsgStop('Usuario nao Encontrado como Operador!')
		Return(0)
	EndIf
EndIf

DbSelectArea('SU0')
DbSetOrder(1)
If !DbSeek(xFilial('SU0')+IIf(!Empty(SA1->A1_GRUPOAT),SA1->A1_GRUPOAT,SU7->U7_POSTO))
	RestArea(_aArea)
	MsgStop('Grupo de Atendimento nao Encontrado!')
	Return(0)
EndIf

If SU0->U0_FAIXAS = 0
	RestArea(_aArea)
	MsgStop('Faixas nao definidas no Grupo de Atendimento!')
	Return(0)
EndIf

If M->UA_POLITIC = "1"
	_nPrecoMin := Posicione('SB0',1,xFilial('SB0')+cProd,'B0_PRV'+Alltrim(Str(SU0->U0_TABMIN,2)))
	_nPrecoMax := Posicione('SB0',1,xFilial('SB0')+cProd,'B0_PRV'+Alltrim(Str(SU0->U0_TABMAX,2)))
ElseIf M->UA_POLITIC = "2"
	_nPrecoMin := Posicione('SB0',1,xFilial('SB0')+cProd,'B0_PRV'+Alltrim(Str(SU0->U0_TABMIN2,2)))
	_nPrecoMax := Posicione('SB0',1,xFilial('SB0')+cProd,'B0_PRV'+Alltrim(Str(SU0->U0_TABMAX2,2)))
EndIf

_aPrecoMin := T_PerAcrePre(_nPrecoMin,M->UA_CONDAF,SU0->U0_CALAFIN,SU0->U0_CALAFRE)
_aPrecoMax := T_PerAcrePre(_nPrecoMax,M->UA_CONDAF,SU0->U0_CALAFIN,SU0->U0_CALAFRE)

_nDescUM2  := Posicione('LH7',1,xFilial('LH7')+cProd,'LH7_DU2'+SU0->U0_CODIGO)
_nDescUM3  := Posicione('LH7',1,xFilial('LH7')+cProd,'LH7_DU3'+SU0->U0_CODIGO)

_nPrecoMin := _aPrecoMin[1]
_nAdFinan  := _aPrecoMin[2]
_nAdFrete  := _aPrecoMin[3]
_nDescDife := _aPrecoMin[4]
_nPrecoMax := _aPrecoMax[1]

_aPrecos    := T_BuscaFaixas(_nPrecoMin,_nPrecoMax,SU0->U0_FAIXAS,(SU0->U0_PEFAI01==0))

_aPrecosPro := T_BuscaPrePro(_cCodPro)

If SU0->U0_PEDAUT == 'S'
	_nDescUM2 := Nil
	If !Empty(aCols[n,aScan(aHeader,{|x|Alltrim(x[2])=='UB_SEGUM'})])
		DbSelectArea('SLK')
		DbSetOrder(3)
		If DbSeek(xFilial('SLK')+_cCodPro) .And. SB1->B1_UM <> SLK->LK_UM
		   _nDescUM2 := SLK->LK_DESCTO
		EndIf		
	EndIf
	If Len(_aPrecosPro)==0
		AtualizaPre(1,_nDescUM2,SLK->LK_UM,If(SLK->LK_UM==SB1->B1_SEGUM,SB1->B1_CONV,If(SLK->LK_UM==SB1->B1_UM3,SB1->B1_UM3FAT,1)))
	Else
		AtualizaPre(10,_nDescUM2,SLK->LK_UM,If(SLK->LK_UM==SB1->B1_SEGUM,SB1->B1_CONV,If(SLK->LK_UM==SB1->B1_UM3,SB1->B1_UM3FAT,1)))
	EndIf
	RestArea(_aAreaSB1)
	RestArea(_aAreaSX5)
	RestArea(_aArea)
	Return(If(Type('M->UA_NUM')<>'U',_nValRet,.T.))
EndIf

For _nX := 1 To Len(_aPrecos)
	If _aPrecos[_nX,1] = 0 .And. _aPrecos[_nX,2] = 0
		RestArea(_aArea)
		MsgStop('Faixas de Precos com inconsistencia!')
		Return(0)
	ElseIf _aPrecos[_nX,3] = 0 .And. SB1->B1_COMIS = 0
		RestArea(_aArea)
		MsgStop('Comissao nas Faixas de Precos nao definida!')
		Return(0)
	EndIf
Next

_nCol := 79.5*Len(_aPrecos)
If _nCol < 350
	_nCol := 350
EndIf
_nCol2:= _nCol/2

While _lSai
	
	DEFINE MSDIALOG oPreco FROM  000,000 TO 230,_nCol TITLE STR0003 PIXEL //"Pre็os do Produto"
	@ 008,002 TO  050,_nCol2
	@ 016,004 SAY STR0004     SIZE  21, 7 //"Codigo"
	@ 015,033 GET _cCodPro    SIZE 115, 9 When .F.
	@ 035,004 SAY STR0005     SIZE  32, 7 //"Descricao"
	@ 034,033 GET _cDesPro    SIZE 135, 9 When .F.
	@ 052,004 SAY STR0006 //"Escolha o pre็o desejado: "
	@ 060,002 TO  111,_nCol2

	If Len(_aPrecosPro) = 0
		If Len(_aPrecos)>0
			@ 064,005 BUTTON Alltrim(Str(_aPrecos[1,2],10,4)) SIZE 30,15 ACTION AtualizaPre(1)
			If !Empty(SB1->B1_SEGUM)
				@ 088,005 SAY SB1->B1_SEGUM+'/'+Alltrim(Str(SB1->B1_CONV,3)) SIZE 15,15
				@ 088,045 BUTTON Alltrim(Str((_aPrecos[1,2]*SB1->B1_CONV)*(1-(_nDescUM2/100)),10,4)) SIZE 30,15 ACTION AtualizaPre(1,_nDescUM2,SB1->B1_SEGUM,SB1->B1_CONV)
			EndIf
			If !Empty(SB1->B1_UM3)
				@ 088,085 SAY SB1->B1_UM3+'/'+Alltrim(Str(SB1->B1_UM3FAT,3)) SIZE 15,15
				@ 088,125 BUTTON Alltrim(Str((_aPrecos[1,2]*SB1->B1_UM3FAT)*(1-(_nDescUM3/100)),10,4)) SIZE 30,15 ACTION AtualizaPre(1,_nDescUM3,SB1->B1_UM3,SB1->B1_UM3FAT)
			EndIf
		EndIf
		If Len(_aPrecos)>1 .And. _aPrecos[1,2] <> _aPrecos[2,2]
			@ 064,045 BUTTON Alltrim(Str(_aPrecos[2,2],10,4)) SIZE 30,15 ACTION AtualizaPre(2)
		EndIf
		If Len(_aPrecos)>2
			@ 064,085 BUTTON Alltrim(Str(_aPrecos[3,2],10,4)) SIZE 30,15 ACTION AtualizaPre(3)
		Endif
		If Len(_aPrecos)>3
			@ 064,125 BUTTON Alltrim(Str(_aPrecos[4,2],10,4)) SIZE 30,15 ACTION AtualizaPre(4)
		EndIf
		If Len(_aPrecos)>4
			@ 064,165 BUTTON Alltrim(Str(_aPrecos[5,2],10,4)) SIZE 30,15 ACTION AtualizaPre(5)
		EndIf
		If Len(_aPrecos)>5
			@ 064,205 BUTTON Alltrim(Str(_aPrecos[6,2],10,4)) SIZE 30,15 ACTION AtualizaPre(6)
		EndIf
		If Len(_aPrecos)>6
			@ 064,245 BUTTON Alltrim(Str(_aPrecos[7,2],10,4)) SIZE 30,15 ACTION AtualizaPre(7)
		EndIf
		If Len(_aPrecos)>7
			@ 064,285 BUTTON Alltrim(Str(_aPrecos[8,2],10,4)) SIZE 30,15 ACTION AtualizaPre(8)
		EndIf
		If Len(_aPrecos)>8
			@ 064,325 BUTTON Alltrim(Str(_aPrecos[9,2],10,4)) SIZE 30,15 ACTION AtualizaPre(9)
		EndIf
	Else
		@ 064,005 SAY 'PROMOCAO' SIZE 30,15
		@ 074,005 BUTTON Alltrim(Str(_aPrecosPro[1],10,4)) SIZE 30,15 ACTION AtualizaPre(10)
		@ 092,005 SAY 'INICIO: '+DTOC(_aPrecosPro[2]) SIZE 50,15
		@ 092,070 SAY 'FINAL : '+DTOC(_aPrecosPro[3]) SIZE 50,15
		If !Empty(SB1->B1_SEGUM)
			@ 064,040 SAY SB1->B1_SEGUM+'/'+Alltrim(Str(SB1->B1_CONV,3)) SIZE 15,15
			@ 074,040 BUTTON Alltrim(Str((_aPrecosPro[1]*SB1->B1_CONV)*(1-(_nDescUM2/100)),10,4)) SIZE 30,15 ACTION AtualizaPre(10,_nDescUM2,SB1->B1_SEGUM,SB1->B1_CONV)
		EndIf
		If !Empty(SB1->B1_UM3)
			@ 064,085 SAY SB1->B1_UM3+'/'+Alltrim(Str(SB1->B1_UM3FAT,3)) SIZE 15,15
			@ 074,085 BUTTON Alltrim(Str((_aPrecosPro[1]*SB1->B1_UM3FAT)*(1-(_nDescUM3/100)),10,4)) SIZE 30,15 ACTION AtualizaPre(10,_nDescUM3,SB1->B1_UM3,SB1->B1_UM3FAT)
		EndIf
	EndIf
	
	ACTIVATE MSDIALOG oPreco CENTER
	
End  

RestArea(_aAreaSB1)
RestArea(_aAreaSX5)
RestArea(_aArea)

Return(If(Type('M->UA_NUM')<>'U',_nValRet,.T.))

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAtualizaPreบAutor  ณMicrosiga           บ Data ณ  08/04/05   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                             บฑฑ
ฑฑบ          ณ                                                             บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP8                                                         บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AtualizaPre(_nPre,_nDesc,_cUM,_nQtdUM)
Local _nQuant  := 0
Local _nPreMin := 0
Local _nPreMax := 0

If Type('oPreco') <> 'U'
	Close(oPreco)
EndIf
If Type('M->UA_NUM') <> 'U' .And. Funname(0) = 'TMKA271'
	_nQuant := aCols[n,AsCan(aHeader,{|x|Alltrim(x[2])=='UB_QUANT'})]
	If _nQuant == 0
		_nQuant := 1
	EndIf
	If _nPre < 10 .And. _nDesc == Nil
		aCols[n,AsCan(aHeader,{|x|Alltrim(x[2])=='UB_VRUNIT'})] := _aPrecos[_nPre,2]
		aCols[n,AsCan(aHeader,{|x|Alltrim(x[2])=='UB_PRCTAB'})] := _aPrecos[_nPre,2]
		aCols[n,AsCan(aHeader,{|x|Alltrim(x[2])=='UB_VLRITEM'})]:= _aPrecos[_nPre,2]*_nQuant
		aCols[n,AsCan(aHeader,{|x|Alltrim(x[2])=='UB_BASEICM'})]:= _aPrecos[_nPre,2]*_nQuant
		aCols[n,AsCan(aHeader,{|x|Alltrim(x[2])=='UB_PERCOM'})] := IIF(_aPrecos[_nPre,3]>0,_aPrecos[_nPre,3],SB1->B1_COMIS)
		aCols[n,AsCan(aHeader,{|x|Alltrim(x[2])=='UB_COMISSA'})]:= ((_aPrecos[_nPre,2]*_nQuant)*IIF(_aPrecos[_nPre,3]>0,_aPrecos[_nPre,3],SB1->B1_COMIS))/100
		aCols[n,AsCan(aHeader,{|x|Alltrim(x[2])=='UB_ADFRETE'})]:= _nAdFrete
		aCols[n,AsCan(aHeader,{|x|Alltrim(x[2])=='UB_ADCONDF'})]:= _nAdFinan
		aCols[n,AsCan(aHeader,{|x|Alltrim(x[2])=='UB_DESCDIF'})]:= _nDescDife
		aCols[n,aScan(aHeader,{|x|Alltrim(x[2])=='UB_VLRMIN'})] := _aPrecoMin[1]
		aCols[n,aScan(aHeader,{|x|Alltrim(x[2])=='UB_VLRMAX'})] := _aPrecoMax[1]
		_nValRet := _aPrecos[_nPre,2]
	ElseIf _nPre == 10 .And. _nDesc == Nil
		aCols[n,AsCan(aHeader,{|x|Alltrim(x[2])=='UB_VRUNIT'})] := _aPrecosPro[1]
		aCols[n,AsCan(aHeader,{|x|Alltrim(x[2])=='UB_PRCTAB'})] := _aPrecosPro[1]
		aCols[n,AsCan(aHeader,{|x|Alltrim(x[2])=='UB_VLRITEM'})]:= _aPrecosPro[1]*_nQuant
		aCols[n,AsCan(aHeader,{|x|Alltrim(x[2])=='UB_BASEICM'})]:= _aPrecosPro[1]*_nQuant
		aCols[n,AsCan(aHeader,{|x|Alltrim(x[2])=='UB_PERCOM'})] := _aPrecosPro[4]
		aCols[n,AsCan(aHeader,{|x|Alltrim(x[2])=='UB_COMISSA'})]:= ((_aPrecosPro[1]*_nQuant)*_aPrecosPro[4])/100
		aCols[n,AsCan(aHeader,{|x|Alltrim(x[2])=='UB_ADFRETE'})]:= 0
		aCols[n,AsCan(aHeader,{|x|Alltrim(x[2])=='UB_ADCONDF'})]:= 0
		aCols[n,AsCan(aHeader,{|x|Alltrim(x[2])=='UB_DESCDIF'})]:= 0
		aCols[n,aScan(aHeader,{|x|Alltrim(x[2])=='UB_VLRMIN'})] := _aPrecosPro[1]
		aCols[n,aScan(aHeader,{|x|Alltrim(x[2])=='UB_VLRMAX'})] := _aPrecosPro[1]
		_nValRet := _aPrecosPro[1]
	ElseIf _nPre < 10
		_nValRet := _aPrecos[_nPre,2]*(1-(_nDesc/100))
		aCols[n,aScan(aHeader,{|x|Alltrim(x[2])=='UB_SEGUM'})]  := _cUM
		aCols[n,aScan(aHeader,{|x|Alltrim(x[2])=='UB_UNSVEN'})] := 1
		If !Empty(SB1->B1_SEGUM) .And. SB1->B1_SEGUM = aCols[n,AsCan(aHeader,{|x|Alltrim(x[2])=='UB_SEGUM'})] .And. _nDescUM2 > 0
			_nPreMin := _aPrecoMin[1]*(1-(_nDescUM2/100)) 
			_nPreMax := _aPrecoMax[1]*(1-(_nDescUM2/100)) 
		ElseIf !Empty(SB1->B1_UM3) .And. SB1->B1_UM3 = aCols[n,AsCan(aHeader,{|x|Alltrim(x[2])=='UB_SEGUM'})] .And. _nDescUM3 > 0
			_nPreMin := _aPrecoMin[1]*(1-(_nDescUM3/100)) 
			_nPreMax := _aPrecoMax[1]*(1-(_nDescUM3/100)) 
		EndIf
		aCols[n,AsCan(aHeader,{|x|Alltrim(x[2])=='UB_QUANT'})]  := _nQtdUM
		aCols[n,AsCan(aHeader,{|x|Alltrim(x[2])=='UB_VRUNIT'})] := _nValRet
		aCols[n,AsCan(aHeader,{|x|Alltrim(x[2])=='UB_PRCTAB'})] := _nValRet
		aCols[n,AsCan(aHeader,{|x|Alltrim(x[2])=='UB_VLRITEM'})]:= _nValRet*_nQtdUM
		aCols[n,AsCan(aHeader,{|x|Alltrim(x[2])=='UB_BASEICM'})]:= _nValRet*_nQtdUM
		aCols[n,AsCan(aHeader,{|x|Alltrim(x[2])=='UB_PERCOM'})] := If(_aPrecos[_nPre,3]>0,_aPrecos[_nPre,3],SB1->B1_COMIS)
		aCols[n,AsCan(aHeader,{|x|Alltrim(x[2])=='UB_COMISSA'})]:= ((_nValRet*_nQtdUM)*IIF(_aPrecos[_nPre,3]>0,_aPrecos[_nPre,3],SB1->B1_COMIS))/100
		aCols[n,AsCan(aHeader,{|x|Alltrim(x[2])=='UB_ADFRETE'})]:= _nAdFrete
		aCols[n,AsCan(aHeader,{|x|Alltrim(x[2])=='UB_ADCONDF'})]:= _nAdFinan
		aCols[n,AsCan(aHeader,{|x|Alltrim(x[2])=='UB_DESCDIF'})]:= _nDescDife
		aCols[n,aScan(aHeader,{|x|Alltrim(x[2])=='UB_VLRMIN'})] := _nPreMin
		aCols[n,aScan(aHeader,{|x|Alltrim(x[2])=='UB_VLRMAX'})] := _nPreMax
	ElseIf _nPre == 10
		_nValRet := _aPrecosPro[1]*(1-(_nDesc/100))
		aCols[n,aScan(aHeader,{|x|Alltrim(x[2])=='UB_SEGUM'})]  := _cUM
		aCols[n,aScan(aHeader,{|x|Alltrim(x[2])=='UB_UNSVEN'})] := 1
		If !Empty(SB1->B1_SEGUM) .And. SB1->B1_SEGUM = aCols[n,AsCan(aHeader,{|x|Alltrim(x[2])=='UB_SEGUM'})] .And. _nDescUM2 > 0
			_nPreMin := _aPrecosPro[1]*(1-(_nDescUM2/100)) 
			_nPreMax := _aPrecosPro[1]*(1-(_nDescUM2/100)) 
		ElseIf !Empty(SB1->B1_UM3) .And. SB1->B1_UM3 = aCols[n,AsCan(aHeader,{|x|Alltrim(x[2])=='UB_SEGUM'})] .And. _nDescUM3 > 0
			_nPreMin := _aPrecosPro[1]*(1-(_nDescUM3/100)) 
			_nPreMax := _aPrecosPro[1]*(1-(_nDescUM3/100)) 
		EndIf		
		aCols[n,AsCan(aHeader,{|x|Alltrim(x[2])=='UB_QUANT'})]  := _nQtdUM
		aCols[n,AsCan(aHeader,{|x|Alltrim(x[2])=='UB_VRUNIT'})] := _nValRet
		aCols[n,AsCan(aHeader,{|x|Alltrim(x[2])=='UB_PRCTAB'})] := _nValRet
		aCols[n,AsCan(aHeader,{|x|Alltrim(x[2])=='UB_VLRITEM'})]:= _nValRet*_nQtdUM
		aCols[n,AsCan(aHeader,{|x|Alltrim(x[2])=='UB_BASEICM'})]:= _nValRet*_nQtdUM
		aCols[n,AsCan(aHeader,{|x|Alltrim(x[2])=='UB_PERCOM'})] := _aPrecosPro[4]
		aCols[n,AsCan(aHeader,{|x|Alltrim(x[2])=='UB_COMISSA'})]:= ((_nValRet*_nQtdUM)*_aPrecosPro[4])/100
		aCols[n,AsCan(aHeader,{|x|Alltrim(x[2])=='UB_ADFRETE'})]:= 0
		aCols[n,AsCan(aHeader,{|x|Alltrim(x[2])=='UB_ADCONDF'})]:= 0
		aCols[n,AsCan(aHeader,{|x|Alltrim(x[2])=='UB_DESCDIF'})]:= 0
		aCols[n,aScan(aHeader,{|x|Alltrim(x[2])=='UB_VLRMIN'})] := _aPrecosPro[1]
		aCols[n,aScan(aHeader,{|x|Alltrim(x[2])=='UB_VLRMAX'})] := _aPrecosPro[1]
	EndIf
EndIf
_lSai:=.F.
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPerAcrePreบAutor  ณMicrosiga           บ Data ณ  08/04/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP8                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/  

Template Function PerAcrePre(_nPre,_cCond,_cConsi1,_cConsi2)
// _nPre = Preco a ser calculado
// _cCond = Condicao de pagamento
// _cConsi1 = Considera acrescimo da Condicao de Pagamento
// _cConsi2 = Considera acrescimo do Frete
// Lembrando que o cliente, o produto e o grupo de atendimento  devem estar posicionados
Local _nAcresF    := 0 //Valor do acrescimo financeiro
Local _nFre       := 0 //Valor do acrescimo de frete
Local _nDif       := 0 //Valor do desconto pela diferenca de icms do estado
Local nAliq		  := 0 //Aliquota em uso
Local _nPreAcre := _nPre

// Calculo da Condicao de Pagamento
_nAcresF := Posicione('SE4',1,xFilial('SE4')+_cCond,'E4_ACREDCM')
If _nAcresF > 0 .And. _cConsi1 = 'S'
	_nPreAcre := Round(_nPreAcre  * _nAcresF,4)
EndIf

If _cConsi2 = 'S'
	_nFre := 0
	If Posicione('LH8',1,xFilial('LH8')+SA1->A1_EST+SA1->A1_MUN+SB1->B1_GRUPO,'LH8_PERCEN') > 0
		_nFre := LH8->LH8_PERCEN
	ElseIf Posicione('LH8',1,xFilial('LH8')+SA1->A1_EST+'9999999'+SB1->B1_GRUPO,'LH8_PERCEN') > 0
		_nFre := LH8->LH8_PERCEN
	EndIf
	If _nFre > 0
		_nPreAcre := Round(_nPreAcre * (1+(_nFre/100)),4)
	EndIf
EndIf
DbSelectArea('LH0')

If SU0->U0_DIFICM1 > 0 .Or. SU0->U0_DIFICM2 > 0 .Or. SU0->U0_DIFICM3 > 0
	nAliq := AliqIcms("N","S",SA1->A1_TIPO,"I")
	_nDif := 0
	If nAliq == 12
		If Empty(SB1->B1_PICM) .or. SB1->B1_PICM == 18
			_nDif := SU0->U0_DIFICM1
		EndIf
	ElseIf nAliq == 7
		If Empty(SB1->B1_PICM) .or. SB1->B1_PICM == 18
			_nDif := SU0->U0_DIFICM2
		ElseIf SB1->B1_PICM == 12
			_nDif := SU0->U0_DIFICM3
		EndIf
	EndIf
	If _nDif > 0
		_nPreAcre := _nPreAcre * _nDif
	EndIf
EndIf

Return({_nPreAcre,_nAcresF,_nFre,_nDif})

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณBuscaFaixasบAutor  ณMicrosiga           บ Data ณ  08/04/05   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                             บฑฑ
ฑฑบ          ณ                                                             บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP8                                                         บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Template Function BuscaFaixas(_nBFMin,_nBFMax,_nBFFaixas,_lBFFaixas)
Local _nX
// Lembrando que o grupo de atendimento  deve estar posicionado
Local _nPrecoMiA := _nPrecoMi := _nBFMin
Local _nValFaixa := 0
Local _aBFPrecos := {}

If _lBFFaixas .And. _nBFFaixas > 3 .And. (_nBFMax - _nBFMin) > 0
	_nValFaixa := (_nBFMax - _nBFMin) / (_nBFFaixas-1)
ElseIf _lBFFaixas .And. _nBFFaixas == 3 .And. (_nBFMax - _nBFMin) > 0
	_nValFaixa := (_nBFMax - _nBFMin) / 2
EndIf

For _nX := 1 To _nBFFaixas
	If (_nBFMax - _nBFMin) > 0 .And. !_lBFFaixas
		If _nX > 2
			_cPerFaiA:= 'SU0->U0_PEFAI'+StrZero(_nX-2,2)
			_nPrecoMiA:= _nBFMin*(1+(&_cPerFaiA/100))
		Endif
		If _nX < 8
			_cPerFai := 'SU0->U0_PEFAI'+StrZero(_nX,2)
			_nPrecoMi := _nBFMin*(1+(&_cPerFai /100))
		EndIf
	ElseIf (_nBFMax - _nBFMin) > 0
		If _nX > 1
			_nPrecoMi  += _nValFaixa
			_nPrecoMiA += _nValFaixa
		EndIf
		If _nX = 2
			_nPrecoMiA-= _nValFaixa
		EndIf
		If _nBFMin == _nBFMax
			_nBFMax := _nPrecoMi
		EndIf
	EndIf
	_cCoFai  := 'SU0->U0_COFAI'+StrZero(_nX,2)
	If (_nBFMax - _nBFMin) > 0
		If _nX < _nBFFaixas .And. _nX > 1
			AaDd(_aBFPrecos,{_nPrecoMiA,_nPrecoMi,&_cCoFai})
		ElseIf _nX = 1
			AaDd(_aBFPrecos,{0,_nBFMin,&_cCoFai})
		Else
			AaDd(_aBFPrecos,{_nPrecoMiA,_nPrecoMi,&_cCoFai})
		EndIf
	Else
		If _nX = 1
			AaDd(_aBFPrecos,{0,_nBFMin,&_cCoFai})
		ElseIf _nX = 2
			AaDd(_aBFPrecos,{_nBFMin,_nBFMax,&_cCoFai})
		EndIf
	EndIf
Next _nX
Return(_aBFPrecos)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณBuscaPreProบAutor  ณMicrosiga           บ Data ณ  08/04/05   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Busca se o produto possui promocao                          บฑฑ
ฑฑบ          ณ                                                             บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP8                                                         บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Template Function BuscaPrePro(_cBPPProd)
Local _aPrePro := {}
Local _nPrePro := 0
Local _aBPPArea:= GetArea()
DbSelectArea('LH7')
DbSetOrder(1)
If DbSeek(xFilial('LH7')+_cBPPProd)
	_cX := '(dDatabase >= LH7->LH7_DATI'+SU0->U0_CODIGO+' .And. dDatabase <= LH7->LH7_DATF'+SU0->U0_CODIGO+')'
	If &_cX
		_cX := 'LH7->LH7_PRO'+SU0->U0_CODIGO
		_nPrePro := &_cX
		_cX1 := 'LH7->LH7_DATI'+SU0->U0_CODIGO
		_cX2 := 'LH7->LH7_DATF'+SU0->U0_CODIGO
		_cX3 := 'LH7->LH7_COMP'+SU0->U0_CODIGO
		AADD(_aPrePro,_nPrePro)
		AADD(_aPrePro,&_cX1)
		AADD(_aPrePro,&_cX2)
		AADD(_aPrePro,&_cX3)
	Endif
EndIf
RestArea(_aBPPArea)
Return(_aPrePro)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAtuTotais บAutor  ณMicrosiga           บ Data ณ  08/04/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP8                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function AtuTotais()

Local aArea		:= GetArea() 						// Salva a area atual
Local nPQtd     := aPosicoes[4][2]					// Posicao da Quantidade
Local nPPrcUni  := aPosicoes[5][2]					// Posicao do Valor Unitario
Local nPVlrItem := aPosicoes[6][2]					// Posicao do Valor do item

MaFisAlt("IT_PRCUNI",aCols[n][nPPrcUni],n)
aCols[n][nPVlrItem] := aCols[n][nPPrcUni] * aCols[n][nPQtd]

MaFisAlt("IT_VALMERC",aCols[n][nPVlrItem],n)
If MaFisFound()
	MaColsToFis(aHeader,aCols,,"TK271",.T.)
	Eval(bRefresh)
EndIf
RestArea(aArea)
Return(aCols[n][nPPrcUni])