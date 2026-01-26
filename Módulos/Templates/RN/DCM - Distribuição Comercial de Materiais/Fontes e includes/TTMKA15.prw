#INCLUDE "TTMKA15.ch"
#include "rwmake.ch"
#include "TOPCONN.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTTMKA15   บAutor  ณEwerton C Tomaz     บ Data ณ  ??/??/??   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Gatilho para nao permitir desconto maior que estabelecido  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Template Function TTMKA15(_cCodigo,_nValor,_nValorMin,_cSegum,_cPostosOk)
Local _nResul := _nValor
Local _aAreaTA15 := GetArea()

If _nValor < (_nValorMin*((100-GetMv("MV_DESCMAX"))/100)) .AND. Empty(_cSegum) .AND. !(IIf(!Empty(SA1->A1_GRUPOAT),SA1->A1_GRUPOAT,SU7->U7_POSTO)$_cPostosOk)
	_nResul := 0
ElseIf !Empty(_cSegum) .AND. !(IIf(!Empty(SA1->A1_GRUPOAT),SA1->A1_GRUPOAT,SU7->U7_POSTO)$_cPostosOk)
	DbSelectArea("SB1")
	DbSetOrder(1)
	DbSeek(xFilial("SB1")+_cCodigo)

	DbSelectArea("LH7")
	DbSetOrder(1)
	DbSeek(xFilial("LH7")+_cCodigo)
	
	_cComando := "LH7->LH7_DU2"+Alltrim(IIf(!Empty(SA1->A1_GRUPOAT),SA1->A1_GRUPOAT,SU7->U7_POSTO))
	_cComando2:= "LH7->LH7_DU3"+Alltrim(IIf(!Empty(SA1->A1_GRUPOAT),SA1->A1_GRUPOAT,SU7->U7_POSTO))
	                    
	If _cSegum == SB1->B1_SEGUM
		If _nValor < ((_nValorMin*((100-&_cComando))/100)*((100-GetMv("MV_DESCMAX"))/100))
			_nResul := 0
		Endif
	ElseIf _cSegum == SB1->B1_UM3
		If _nValor < ((_nValorMin*((100-&_cComando2))/100)*((100-GetMv("MV_DESCMAX"))/100))
			_nResul := 0
		Endif
	Endif
Endif

RestArea(_aAreaTA15)
Return	_nResul