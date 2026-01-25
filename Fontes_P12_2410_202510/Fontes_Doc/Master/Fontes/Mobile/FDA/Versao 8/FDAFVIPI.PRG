#include "FDAXFIS.CH"
/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбдддддддддддбдддддддбддддддддддддддддддддддбддддддбдддддддддддд©╠╠
╠╠ЁFun┤┘o    ЁFdaValIpi  Ё Autor Ё Henry Fila           Ё Data Ё 18.10.2004 Ё╠╠
╠╠цддддддддддедддддддддддадддддддаддддддддддддддддддддддаддддддадддддддддддд╢╠╠
╠╠ЁDescri┤┘o Ё Calcula o valor do IPI                                       Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё Uso      Ё Generico                                                     Ё╠╠
╠╠цддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                       Ё╠╠
╠╠цддддддддддддддбддддддддбддддддбдддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё PROGRAMADOR  Ё DATA   Ё BOPS Ё  MOTIVO DA ALTERACAO                     Ё╠╠
╠╠цддддддддддддддеддддддддеддддддедддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё              Ё        Ё      Ё                                          Ё╠╠
╠╠юддддддддддддддаддддддддаддддддадддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Function FdaValIpi(nItem,aFdaNfCab,aFdaNfItem)   
Local cChaveB1:=RetFilial("HB1")+aFdaNfItem[nItem,IT_PRODUTO]     
Local cChaveF4:=RetFilial("HF4")+aFdaNfItem[nItem,IT_TES]

dbSelectArea("HB1")
dbSetOrder(1)
dbSeek(cChaveB1)

dbSelectArea("HF4")
dbSetOrder(1)
dbSeek(cChaveF4)

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Calcula o valor do IPI                                      Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If ( HF4->HF4_IPI <> "N" )
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Calculo do IPI Normal                                       Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
    
	If HB1->HB1_VLR_IPI == 0
		aFdaNfItem[nItem,IT_VALIPI] := FdaNoRound(aFdaNfItem[nItem,IT_BASEIPI]*aFdaNfItem[nItem,IT_ALIQIPI]/100,2)
	Else
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Calculo do IPI de Pauta                                     Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды	
		aFdaNfItem[nItem,IT_VALIPI] := aFdaNfItem[nItem,IT_QTDVEN]*HB1->HB1_VLR_IPI
	EndIf
Else
	aFdaNfItem[nItem,IT_VALIPI] := 0
EndIf
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Caso nao haja valor do IPI nao se deve ter base de calculo  Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If aFdaNfItem[nItem,IT_VALIPI] == 0
	aFdaNfItem[nItem,IT_BASEIPI]:= 0
EndIf                          

Return
