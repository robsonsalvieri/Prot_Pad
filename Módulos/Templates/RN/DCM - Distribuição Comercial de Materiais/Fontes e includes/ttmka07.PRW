#INCLUDE "ttmka07.ch"
#INCLUDE "rwmake.ch"    

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ TTMKA07 ³ Autor ³ Ewerton C Tomaz        ³ Data ³ 11/12/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Gatilho que faz o tratamento quando na digitação da     	  ³±±
±±³          ³ quantidade verificar o Saldo  Estoque (TMKVCA())        	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Template DCM                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/     

Template Function TTMKA07(nParam)
Local _aAreaT7		:= GetArea()
Local _nPosProd 	:= aScan(aHeader,{|e|Trim(e[2])=="UB_PRODUTO"})      
Local _nPosQuant	:= aScan(aHeader,{|e|Trim(e[2])=="UB_QUANT"})      
Local _nPosComis   	:= aScan(aHeader,{|e|Trim(e[2])=="UB_PERCOM"})    
Local _nPosTotal   	:= aScan(aHeader,{|e|Trim(e[2])=="UB_VLRITEM"})    
Local _cCodProd     := aCols[n][_nPosProd]  
Local _nQuant       := aCols[n][_nPosQuant]
Local nTipo 		:= nParam
CHKTEMPLATE("DCM")  

DbSelectArea("SB2")
Dbsetorder(1)
If !DbSeek(xFilial('SB2')+_cCodProd)
   MsgStop(STR0004) //'Produto sem Saldo Inicial de Estoque cadastrado, contate Administrador de Materiais!'
   RestArea(_aAreaT7)
   Return(0)   
EndIf

_nMix := 0
If T_BuscaSalCon(M->UA_CLIENTE,_cCodProd) = 0
   _nMix := 0 //T_BuscaSalCon('',_cCodProd) 
EndIf   

_nDispo   := (SB2->B2_QATU - (Int(SB2->B2_RESERVA) + Int(SB2->B2_QEMP) + Int(_nMix))) 
// Mix - Acrescentar na reserva a quantidade de mix exceto do cliente 

DbselectArea("SUB")
DbsetOrder(1)
DbSeek(xFilial("SUB")+_cCodProd)

IF _nQuant > _nDispo

  T_TTMKC01(_cCodProd,nTipo)

EndIf

RestArea(_aAreaT7)

Return(_nQuant)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CONSULSD  ºAutor  ³Microsiga           º Data ³  07/26/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Template DCM                                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Template Function CONSULSD(_cTIPO)

CHKTEMPLATE("DCM")  

_cArea := Alias()
_cInd  := IndexOrd()
_cReg  := RecNo()
	                         
If _cTIPO = 'S'	
   _nPosProd 		:= aScan(aHeader,{|e|Trim(e[2])=="C1_PRODUTO"})      
   _nPosQuant 		:= aScan(aHeader,{|e|Trim(e[2])=="C1_QUANT"})
Else
   _nPosProd 		:= aScan(aHeader,{|e|Trim(e[2])=="C7_PRODUTO"})      
   _nPosQuant 		:= aScan(aHeader,{|e|Trim(e[2])=="C7_QUANT"})      
EndIf
	
_cCodProd := aCols[n][_nPosProd]  
_nQuant   := aCols[n][_nPosQuant]  

DbSelectArea("SB2")
Dbsetorder(1)
DbSeek(xFilial('SB2')+_cCodProd+'01')

T_TTMKC01()

DbSelectArea(_cArea)
DbSetOrder(_cInd)
DbGoTo(_cReg)

Return(_cCodProd)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CONSUL_PENDºAutor  ³Microsiga          º Data ³  07/26/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Template DCM                                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Template Function CONSUL_PEND(_cCliente,_cLoja,_cProd)

CHKTEMPLATE("DCM")  

_cArea := Alias()
_cInd  := IndexOrd()
_cReg  := RecNo()
DbSelectArea('SC9')
DbSetOrder(8)
If DbSeek(xFilial('SC9')+_cProd+_cCliente+_cLoja)
   While SC9->(! Eof()) .AND. SC9->C9_FILIAL == xFilial('SC9') .AND. SC9->C9_PRODUTO == _cProd .AND. SC9->C9_CLIENTE == _cCliente .AND. SC9->C9_LOJA == _cLoja
      If Empty(SC9->C9_NFISCAL) .And. SC9->C9_BLEST = '02'
         MsgStop(STR0001+TransForm(SC9->C9_QTDLIB,'@ER 999,999.99')+' itens'+Chr(13)+; //'Cliente ja possui pendencia para este produto de '
                 STR0002+DtoC(SC9->C9_DATALIB)+STR0003+SC9->C9_PEDIDO) //'A pendencia foi gerada em '###' no pedido '
      EndIf
      DbSkip()
   End  
EndIf

DbSelectArea(_cArea)
DbSetOrder(_cInd)
DbGoto(_cReg)

Return(_cProd)


