#include "rwmake.ch" 


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออออออออปฑฑ
ฑฑบ Funcao   ณ CBMT175ATU บ Autor ณ Anderson Rodrigues บ Data ณMon  16/09/02     บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออออออออนฑฑ
ฑฑบDescrio ณAcerto do CB0 no estorno do CQ via Protheus					 	 นฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAACD                                                           บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function CBMT175ATU(lA175Ender)

local lMVCBPE010	:= !SuperGetMV("MV_CBPE010",.F.,.F.)
local lMVPDEVLOC	:= SuperGetMV("MV_PDEVLOC",.F.,2) == 2

lA175Ender := if(Type('lA175Ender') == "L", lA175Ender, .F.) 

If lMVCBPE010
	Return .t.
EndIf

If __cInternet == "AUTOMATICO"
   Return .t.
Endif

If !lEstorno		
   Return .t.
Endif

If lA175Ender .and. lMVPDEVLOC
   MsgBox("Atencao o parametro MV_PDEVLOC nao esta configurado corretamente, Verifique !!!","STOP")
   Return .f.
Endif

Return .t.
