#INCLUDE "ttmka08.ch"
#INCLUDE "rwmake.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TTMKA08   ºAutor  ³Ewerton C Tomaz     º Data ³  ??/??/??   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Atualiza o aCols a Partir do LH3                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP5                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Template Function TTMKA08()
Local _nX
Local _aAreaT8		:= GetArea()
Local _nAnt			:= n
Local _nPosTotal	:= aScan(aHeader,{|e|Trim(e[2])=="UB_VLRITEM"})
Local _nPosPerCom	:= aScan(aHeader,{|e|Trim(e[2])=="UB_PERCOM"})
Local _nPosComissa	:= aScan(aHeader,{|e|Trim(e[2])=="UB_COMISSA"})
Local _nPosPreUni	:= aScan(aHeader,{|e|Trim(e[2])=="UB_VRUNIT"})
Local _nPosTES   	:= aScan(aHeader,{|e|Trim(e[2])=="UB_TES"})
Local _nPosQuant   	:= aScan(aHeader,{|e|Trim(e[2])=="UB_QUANT"})
Local _nPosProd   	:= aScan(aHeader,{|e|Trim(e[2])=="UB_PRODUTO"})
Local _nPrecoMin    := _nPrecoMax := _nPerCom := 0
Local _aPrecos      := {}
Local _nPreco       := If(Type("M->UB_VRUNIT")=="U",aCols[n,_nPosPreUni],M->UB_VRUNIT)
Local _nQuant       := If(Type("M->UB_QUANT")=="U",aCols[n,_nPosQuant],M->UB_QUANT)

DbSelectArea('SU0')
DbSetOrder(1)
If !DbSeek(xFilial('SU0')+If(!Empty(SA1->A1_GRUPOAT),SA1->A1_GRUPOAT,SU7->U7_POSTO))
	MsgStop(STR0001) //'Grupo de Atendimento nao Encontrado!'
	RestArea(_aAreaT8)
	n		:= _nAnt
	Return(0)
EndIf

If SU0->U0_FAIXAS = 0
	MsgStop(STR0002) //'Faixas nao definidas no Grupo de Atendimento!'
	RestArea(_aAreaT8)
	n		:= _nAnt
	Return(0)
EndIf

_nPrecoMin := aCols[n,aScan(aHeader,{|e|Trim(e[2])=="UB_VLRMIN"})]
_nPrecoMax := aCols[n,aScan(aHeader,{|e|Trim(e[2])=="UB_VLRMAX"})]

_aPrecos := T_BuscaFaixas(_nPrecoMin,_nPrecoMax,SU0->U0_FAIXAS,(SU0->U0_PEFAI01==0))

_aPrecosPro := T_BuscaPrePro(aCols[n,_nPosProd])

If Len(_aPrecosPro) == 0
	For _nX := 1 To Len(_aPrecos)
		If _aPrecos[_nX,1] = 0 .And. _aPrecos[_nX,2] = 0
			RestArea(_aAreaT8)
			MsgStop(STR0003) //'Faixas de Precos com inconsistencia!'
			n := _nAnt
			Return(0)
		ElseIf _aPrecos[_nX,3] = 0 .And. SB1->B1_COMIS = 0
			RestArea(_aAreaT8)
			MsgStop(STR0004) //'Comissao nas Faixas de Precos nao definida!'
			n := _nAnt
			Return(0)
		EndIf
		If _nX < Len(_aPrecos)
			If  _nPreco >= _aPrecos[_nX+1,1] .And. _nPreco < _aPrecos[_nX+1,2]
				_nPerCom := IIF(_aPrecos[_nX,3]>0,_aPrecos[_nX,3],SB1->B1_COMIS)
				Exit
			ElseIf _nX == 1 .And. _nPreco < _aPrecos[_nX+1,1]
				_nPerCom := If(_aPrecos[_nX,3]>0,_aPrecos[_nX,3],SB1->B1_COMIS)
				Exit
			EndIf
		Else
			If Round(_nPreco,2) >= Round(_aPrecos[_nX,2],2)
				_nPerCom := If(_aPrecos[_nX,3]>0,_aPrecos[_nX,3],SB1->B1_COMIS)
				Exit
			EndIf
		EndIf
	Next
Else
	_nPerCom := If(_nPerCom==0,_aPrecosPro[4],_nPerCom)
EndIf

If T_BuscaValCon(M->UA_CLIENTE,'').And.;
	((!Empty(LH4->LH4_NUMORC) .And. LH4->LH4_NUMORC = M->UA_NUM) .Or. Empty(LH4->LH4_NUMORC))
	_nPerCom := If(!Empty(LH4->LH4_COMISS),LH4->LH4_COMISS,_nPerCom)
EndIf

aCols[n][_nPosTotal]   := _nPreco * _nQuant
aCols[n][_nPosPerCom]  := _nPerCom
aCols[n][_nPosComissa] := aCols[n][_nPosTotal] * (_nPerCom/100)

MaFisRef("IT_VALMERC","TK273",aCols[N,_nPosTotal])
MaFisRef("IT_TES","TK273",aCols[N,_nPosTES])
Tk273Trigger()

RestArea(_aAreaT8)
n		:= _nAnt
Return(_nPerCom)
