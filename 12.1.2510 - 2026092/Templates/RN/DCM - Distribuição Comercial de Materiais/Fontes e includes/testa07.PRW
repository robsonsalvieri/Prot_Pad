#INCLUDE "rwmake.ch"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TESTA07.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTESTA07   บ Autor ณ Ewerton C Tomaz    บ Data ณ  09/11/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณLiberacao Automatica de Pedidos Pendentes                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5 IDE                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Template Function TESTA07()
Local _aOrdLib := {}
Local _aOrdLibDef := {}
Local _nX

Private aPedLib := {}

// Informar no parametro MV_SEGCLIE os codigos de atividades que serใo priorizados na liberacao
_aOrdLib := {}
AaDd(_aOrdLib,{1," AND A1_EST <> '"+GetMV("MV_ESTADO") + IIf(!Empty(GetNewPar("MV_SEGCLIE","",xFilial("SA1"))),"' AND A1_SATIV1 IN ("+GetMV("MV_SEGCLIE")+") "," ' ")})
AaDd(_aOrdLib,{2," AND A1_EST =  '"+GetMV("MV_ESTADO") + IIf(!Empty(GetNewPar("MV_SEGCLIE","",xFilial("SA1"))),"' AND A1_SATIV1 IN ("+GetMV("MV_SEGCLIE")+") "," ' ")})
If !Empty(GetNewPar("MV_SEGCLIE","",xFilial("SA1")))
	AaDd(_aOrdLib,{3," AND A1_EST <> '"+GetMV("MV_ESTADO")+"' AND A1_SATIV1 NOT IN ("+GetMV("MV_SEGCLIE")+") "})
	AaDd(_aOrdLib,{4," AND A1_EST = '"+GetMV("MV_ESTADO")+"' AND A1_SATIV1 NOT IN ("+GetMV("MV_SEGCLIE")+") "})
Else
	AaDd(_aOrdLib,{3,""})
	AaDd(_aOrdLib,{4,""})
Endif

_aOrdLibDef := T_Split(GetNewPar("MV_DCMORDL","1,2,3,4",xFilial("SA1")),",")
If Len(_aOrdLibDef) == 4
	For _nX := 1 To Len(_aOrdLib)
		_aOrdLib[_nX,1] := Val(_aOrdLibDef[_nX])
	Next
Endif
aSort(_aOrdLib,,,{|x,y| x[1] < y[1]})

While Pergunte("ESTA07",.T.)
	
	aPedLib := {}
	                                                                                                       
	// Informar no parametro MV_USUGER o nome dos usuarios que poderao liberar todos os pedidos de uma s๓ vez
	If Empty(MV_PAR01) .And. !(Upper(Rtrim(CUSERNAME)) $ Alltrim(Upper(GetNewPar("MV_USUGER","ADMINISTRADOR",xFilial("SC5")))))
		MsgStop(STR0009) //"Somente usuแrios parametrizados como Gerentes podem executar a rotina para todos os pedidos!"
		Loop
	Endif
	
	If MV_PAR07 = 1
		Processa( {|| Proclib(_aOrdLib[1,2]) },STR0010+Alltrim(Str(_aOrdLib[1,1]))+"..." ) //"Processando Pedidos Ordem "
		Processa( {|| Proclib(_aOrdLib[2,2]) },STR0010+Alltrim(Str(_aOrdLib[2,1]))+"..." ) //"Processando Pedidos Ordem "
		Processa( {|| Proclib(_aOrdLib[3,2]) },STR0010+Alltrim(Str(_aOrdLib[3,1]))+"..." ) //"Processando Pedidos Ordem "
		Processa( {|| Proclib(_aOrdLib[4,2]) },STR0010+Alltrim(Str(_aOrdLib[4,1]))+"..." ) //"Processando Pedidos Ordem "
	Else
		Processa( {|| Proclib("") },STR0011 ) //"Processando Pedidos..."
	Endif
	
	If Len(aPedLib) > 0
		cNotaEnt:= "TESTA7"
		cSerEnt := "SB2"
		cFornec := " "
		cLojaFor:= " "
		If GetMv("MV_IMPPENR") = "S"
			If ExistBlock("TFATR01")
				If !Empty(MV_PAR01)
					U_TFATR01(2,aPedLib,"","","","")
				Else
					U_TFATR01(2,aPedLib,cNotaEnt,cSerEnt,cFornec,cLojaFor)
				Endif
			Else
				If !Empty(MV_PAR01)
					T_TFATR01(2,aPedLib,"","","","")
				Else
					T_TFATR01(2,aPedLib,cNotaEnt,cSerEnt,cFornec,cLojaFor)
				Endif
			Endif
		Else
			MsgBox(STR0049 +Chr(13)+ STR0050 ,STR0051,STR0052)  //'Foram Liberados Pedidos Pendentes Apartir desta Movimentacao,' - 'Comunique Setor de Separacao!' -'Informacao' - 'INFO'			
		Endif
	Else
		MsgStop(STR0053 ) //'Nao Existem Pedidos Pendentes Para Liberar'
	Endif
EndDo

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณProclib   บ Autor ณ Ewerton C Tomaz    บ Data ณ  09/11/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5 IDE                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function Proclib(_cTipo)
LOCAL cQueryCad := SPACE(1)
LOCAL nQuantR := 0
LOCAL _nCount := 0
Local _nX
Local _aIteLib:= {}
Local _aIteBlq:= {}
Local _nY

DbSelectArea('SC9')
DbSetOrder(1)
DbSelectArea('SC5')
DbSetOrder(1)
DbSelectArea('SC6')
DbSetOrder(1)
DbSelectArea('SB2')
DbSetOrder(1)

For _nX := 1 To 2
	If _nX = 1
		cQueryCad := "SELECT Count(C9_PEDIDO) AS TOTAL FROM "+RetSqlName("SC9")+" SC9, "+RetSqlName("SC6")+" SC6, "+RetSqlName("SA1")+" SA1 WHERE"
	Else
		cQueryCad := "SELECT C9_FILIAL,C9_PEDIDO,C9_ITEM,C9_SEQUEN,C9_PRODUTO,C9_BLCRED,C9_BLPRE,C9_QTDLIB,C9_PRCVEN,C6_ENTREG,C9_LOCAL FROM "+RetSqlName("SC9")+" SC9, "+RetSqlName("SC6")+" SC6, "+RetSqlName("SA1")+" SA1 WHERE"
	Endif
	cQueryCad += " SC9.D_E_L_E_T_ <> '*' AND"
	cQueryCad += " SC6.D_E_L_E_T_ <> '*' AND"
	cQueryCad += " SA1.D_E_L_E_T_ <> '*' AND "
	cQueryCad += " C9_FILIAL = '"+xFilial("SC9")+"' AND"
	cQueryCad += " C9_PEDIDO = C6_NUM AND "
	cQueryCad += " C9_ITEM   = C6_ITEM AND "
	cQueryCad += " C6_BLQ     <> 'R' AND "
	cQueryCad += " C6_QTDENT  < C6_QTDVEN AND "
	cQueryCad += " C9_BLEST   <> ' ' AND "
	If MV_PAR09 = 1
		cQueryCad += " C9_BLCRED  =  ' ' AND "
	Endif
	cQueryCad += " A1_COD  = C9_CLIENTE AND "
	cQueryCad += " A1_LOJA = C9_LOJA "
	
	If !Empty(MV_PAR01)
		cQueryCad += " AND C9_PEDIDO = '"+MV_PAR01+"' "
	Endif
	
	If !Empty(MV_PAR02)
		cQueryCad += " AND C9_PRODUTO = '"+MV_PAR02+"' "
	Endif
	
	If MV_PAR03 = 1
		cQueryCad += " AND C6_ENTREG <= '"+DTOS(MV_PAR04)+"' "
	Endif
	
	If !Empty(MV_PAR05)
		cQueryCad += " AND C9_LINHA = '"+MV_PAR05+"' "
	Endif
	
	If !Empty(MV_PAR06)
		cQueryCad += " AND C9_COLEC = '"+MV_PAR06+"' "
	Endif
	
	If _cTipo <> ""
		cQueryCad += _cTipo
	Endif
	
	If _nX = 2
		cQueryCad += " ORDER BY C9_FILIAL, "+IIf("A1_SATIV1 IN"$_cTipo," A1_SATIV1, ","")+"C9_PEDIDO, C9_ITEM, C9_SEQUEN, C9_PRODUTO"
	Endif
	
	TCQUERY cQueryCad NEW ALIAS "PROLIB"
	
	If _nX = 1
		_nCount := PROLIB->TOTAL
		PROLIB->(DbCloseArea())
	Endif
Next

TCSetField("PROLIB","C6_ENTREG","D",8,0)

DbSelectArea("PROLIB")
Dbgotop()
ProcRegua(_nCount)
Do While !Eof()
	IncProc()
	nQuantR := 0
	
	If !SC5->(DbSeek(xFilial('SC5')+PROLIB->C9_PEDIDO))
		MsgStop(STR0001 + PROLIB->C9_PEDIDO + STR0002) //'Problema na liberacao do Pedido ' - ', Verifique !'
		DbSelectArea("PROLIB")
		DbSkip()
		Loop
	Endif
	
	If !SC6->(DbSeek(xFilial('SC6')+PROLIB->C9_PEDIDO+PROLIB->C9_ITEM))
		MsgStop(STR0001 + PROLIB->C9_PEDIDO+'/'+PROLIB->C9_ITEM+ STR0002) //'Problema na liberacao do Pedido ' - ', Verifique !'
		DbSelectArea("PROLIB")
		DbSkip()
		Loop
	Endif
	
	If !SB2->(DbSeek(xFilial('SB2')+SC6->C6_PRODUTO+SC6->C6_LOCAL) .AND. !Empty(SC6->C6_LOCAL))
		MsgStop(STR0001 + PROLIB->C9_PEDIDO+'/'+PROLIB->C9_ITEM+ STR0002 ) //'Problema na liberacao do Pedido ' - ', Verifique !'
		DbSelectArea("PROLIB")
		DbSkip()
		Loop
	Else
		// Mix - Implementar quantidade do Mix na variavel nQuantR, verificando se
		//       o cliente nao tem quantidade reservada de Mix, se existir Mix para o
		//       cliente segue processamento normal
		_nMix := 0
		If T_BuscaSalCon(SC6->C6_CLI,SC6->C6_LOJA,SC6->C6_PRODUTO) = 0
			_nMix := T_BuscaSalCon('','',SC6->C6_PRODUTO)
		Endif
		
		nQuantR := SB2->B2_RESERVA+_nMix
		If SC9->(DbSeek(xFilial('SC9')+PROLIB->(C9_PEDIDO+C9_ITEM+C9_SEQUEN)))
			If !Empty(SC9->C9_BLEST) .AND. SC9->C9_BLEST <> '10'
				If Empty(MV_PAR01)
					If GRSD3SC9((SB2->B2_QATU-nQuantR),PROLIB->C9_SEQUEN)
						if AsCan(aPedLib, SC9->C9_PEDIDO) = 0
							AaDd(aPedLib, SC9->C9_PEDIDO)
						endif
					Endif
				Else
					AaDd(_aIteLib,{PROLIB->(C9_PEDIDO+C9_ITEM+C9_SEQUEN),; // 01
					     PROLIB->C9_QTDLIB,;                     // 02
					     (SB2->B2_QATU-nQuantR),;                // 03
					     PROLIB->C9_PRCVEN,;                     // 04
					     PROLIB->C9_PRODUTO,;                    // 05
					     PROLIB->C6_ENTREG,;                     // 06
					     PROLIB->C9_LOCAL,;                      // 07
					     PROLIB->C9_BLCRED,;                     // 08
					     PROLIB->C9_BLPRE})                      // 09
				Endif
			Endif
		Endif
	EndIf
	DbSelectArea("PROLIB")
	DbSkip()
End  
If !Empty(MV_PAR01) .And. Len(_aIteLib) > 0
	_nTotLib := 0
	_nTotPen := 0
	_cPedido:= SubStr(_aIteLib[1,1],1,6)
	_cInfPed := STR0012+_cPedido+Chr(13)+Chr(10) //"ANALISE DO PEDIDO: "
	_cInfPed += Chr(13)+Chr(10)
	_nItensL := 0
	_nItensP := 0
	_lCredBLQ:= .F.
	For _nX := 1 To Len(_aIteLib)
		If _aIteLib[_nX,2] <= _aIteLib[_nX,3]
			++_nItensL
			_nTotLib += (_aIteLib[_nX,2]*_aIteLib[_nX,4])
			_cInfPed += STR0013+SubStr(_aIteLib[_nX,1],7,2)+; //"Item LIB: "
			STR0014+_aIteLib[_nX,5]+; //" Produto: "
			STR0015+TransForm(_aIteLib[_nX,2],"@ER 9999999")+; //" Qtd: "
			STR0016+TransForm(_aIteLib[_nX,2]*_aIteLib[_nX,4],"@ER 999,999,999.99")+Chr(13)+Chr(10)+; //" Valor: "
			Space(11)+STR0017+DTOC(_aIteLib[_nX,6])+; //" Entrega: "
			IIf(!Empty(_aIteLib[_nX,8]).Or.Empty(_aIteLib[_nX,9]),STR0018+IIf(!Empty(_aIteLib[_nX,8]),"C","")+IIf(Empty(_aIteLib[_nX,9]),"P",""),"")+Chr(13)+Chr(10) //" Bloqueio: "
		Else
			If MV_PAR08 = 1
				If _aIteLib[_nX,3] > 0
					++_nItensL
				Endif
				++_nItensP
				_nTotLib += (_aIteLib[_nX,3]*_aIteLib[_nX,4])
				_nTotPen += ((_aIteLib[_nX,2]-_aIteLib[_nX,3])*_aIteLib[_nX,4])
			Else
				++_nItensP
				_nTotPen += (_aIteLib[_nX,2]*_aIteLib[_nX,4])
			Endif
			_cInfPed += STR0019+SubStr(_aIteLib[_nX,1],7,2)+; //"Item PEN: "
			STR0014+_aIteLib[_nX,5]+; //" Produto: "
			IIf(MV_PAR08 = 1,Chr(13)+Chr(10),"")+STR0015+TransForm(_aIteLib[_nX,2],"@ER 9999999")+; //" Qtd: "
			IIf(MV_PAR08 = 1," Est Disp: "+TransForm(_aIteLib[_nX,3],"@ER 9999999"),"")+;
			STR0016+TransForm(_aIteLib[_nX,2]*_aIteLib[_nX,4],"@ER 999,999,999.99")+; //" Valor: "
			IIf(MV_PAR08 = 2,Chr(13)+Chr(10)+Space(11),"")+STR0017+DTOC(_aIteLib[_nX,6])+; //" Entrega: "
			IIf(!Empty(_aIteLib[_nX,8]).Or.Empty(_aIteLib[_nX,9]),STR0018+IIf(!Empty(_aIteLib[_nX,8]),"C","")+IIf(Empty(_aIteLib[_nX,9]),"P",""),"")+Chr(13)+Chr(10) //" Bloqueio: "
		Endif
		If !_lCredBLQ .And. !Empty(_aIteLib[_nX,8])
			_lCredBLQ:= .T.
		Endif
	Next
	If _lCredBLQ
		_cInfPed += Chr(13)+Chr(10)
		_cInfPed += STR0020+Chr(13)+Chr(10) //"CREDITO BLOQUEADO!"
	Endif
	_cInfPed += Chr(13)+Chr(10)
	_cInfPed += STR0021+TransForm(_nItensL,"@ER 9999")+Chr(13)+Chr(10) //"Total de Itens Liberados..: "
	If _nItensP > 0
		_cInfPed += STR0022+TransForm(_nItensP,"@ER 9999")+Chr(13)+Chr(10) //"Total de Itens Pendentes..: "
	Endif
	_cInfPed += Chr(13)+Chr(10)
	_cInfPed += STR0023+TransForm(_nTotLib,"@ER 999,999,999.99")+Chr(13)+Chr(10) //"Total para Faturamento....: "
	_cInfPed += Chr(13)+Chr(10)
	If _nTotPen > 0
		_cInfPed += STR0024+TransForm(_nTotPen,"@ER 999,999,999.99")+Chr(13)+Chr(10) //"Total Pendencias Restantes: "
		_cInfPed += Chr(13)+Chr(10)
	Endif
	
	_aCondPen2:= Posicione("SE4",1,xFilial("SE4")+SC5->C5_CONDPAG,"E4_COND")
	aParcela   := T_Prazo( AllTrim(_aCondPen2), "," )
	_nTotal    := 0
	For _nX := 1 To Len( aParcela )
		_nTotal += iif(_nX>len(aParcela),0,Val(aParcela[_nX]))
	Next
	nMedia  := _nTotal / Len(aParcela)
	nUltDia :=	Val(aParcela[Len(aParcela)])
	
	_cInfPed += STR0025+SC5->C5_CONDPAG+" - "+SE4->E4_DESCRI+Chr(13)+Chr(10) //"Parcelas Conforme Condi็ใo: "
	
	_aCondPen := Condicao(_nTotLib,SC5->C5_CONDPAG,,ddatabase)
	For _nY := 1 To Len(_aCondPen)
		_cInfPed += STR0026+Alltrim(Str(_nY,2))+": "+Alltrim(Str(_aCondPen[_nY,2],10,2))+" - "+DTOC(_aCondPen[_nY,1])+Chr(13)+Chr(10) //"Parcela "
	Next
	_cInfPed += Chr(13)+Chr(10)
	_cInfPed += "M้dia: "+Alltrim(Str(nMedia,4))+IIf(nMedia<>nUltDia," - "+STR0027+Alltrim(Str(nUltDia,4)),"") //"Ultimo Dia: "
	_cInfPed += Chr(13)+Chr(10)
	_cInfPed += STR0028+SC5->C5_POLITIC+Chr(13)+Chr(10) //"Politica: "
	
	_lContinua := .T.
	While _lContinua
		
		_nRes := Aviso(STR0029,_cInfPed,{STR0030,STR0031,STR0032,STR0033},3,STR0034) //"Informa็ใo"###"Sim"###"Nใo"###"Imprimir"###"Email"###"Confirma a Liberacao?"
		
		If _nRes = 1
			Processa({||ConfLib(_aIteLib,nQuantR)},STR0035) //"Processando Liberacoes do Pedido..."
			_lContinua := .F.
		ElseIf _nRes = 3
			If ExistBlock("TFATR01")
				U_TFATR01(3,{_cPedido},"","","","")
			Else                                   
				T_TFATR01(3,{_cPedido},"","","","")
			Endif
		ElseIf _nRes = 4
			T_EmailPen(_cInfPed,STR0036) //"Pendencias do Pedido"
		Else
			_aPedLib := {}
			_lContinua := .F.
		Endif
		
	End  
	
Endif

DbSelectArea("PROLIB")
DbCloseArea()

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณConfLib   บ Autor ณ Ewerton C Tomaz    บ Data ณ  09/11/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5 IDE                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function ConfLib(_aIteLib,nQuantR)
Local _nConIte := 0
Local _lEfetiva:= .T.
ProcRegua(Len(_aIteLib))
SC5->(DbSeek(xFilial("SC5")+_cPedido))
For _nConIte := 1 To Len(_aIteLib)
	If !Empty(_aIteLib[_nConIte,8])
		_lEfetiva:= .F.
	Endif
Next
If IIf(_lEfetiva,.T.,IIf(MsgNoYes(STR0037+Chr(13)+Chr(10)+; //"Pedido com Bloqueio de Cr้dito, Confirma Liberar as Pendencias mesmo assim?"
	STR0038+Chr(13)+Chr(10)+; //"Ao confirmar as pendencias serao liberadas mas o pedido continuarแ"
	STR0039),.T.,.F.)) //"bloqueado no cr้dito."
	For _nConIte := 1 To Len(_aIteLib)
		IncProc()
		If SB2->(DbSeek(xFilial("SB2")+_aIteLib[_nConIte,5]+_aIteLib[_nConIte,7])) .And.;
			SC6->(DbSeek(xFilial("SC6")+SubStr(_aIteLib[_nConIte,1],1,8))) .And.;
			SC9->(DbSeek(xFilial("SC9")+SubStr(_aIteLib[_nConIte,1],1,8)))
			If GRSD3SC9((SB2->(B2_QATU-B2_RESERVA)),SubStr(_aIteLib[_nConIte,1],9,2),_aIteLib[_nConIte,8])
				if AsCan(aPedLib, SC5->C5_NUM) = 0
					AaDd(aPedLib, SC5->C5_NUM)
				endif
			Endif
		Endif
	Next
Endif
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGRSD3SC9  บ Autor ณ Ewerton C Tomaz    บ Data ณ  09/11/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5 IDE                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function GRSD3SC9(nQtd,cSeqSC9,cCredito)
Local _lLiber   := .F.
Local _nLiberar := 0
Local _nQtdPen:= 0
Local _cLibPre  := ""
Local _aBlqReg  := {}
Local _cPedAnt  := ""
Local _cIteAnt  := ""

_cLibPre := SC9->C9_BLPRE
_nQuant  := nQtd
_nQtdLib := T_VerSegUm(SC6->C6_SEGUM,SC6->C6_PRODUTO,_nQuant,SC6->C6_UNSVEN)
If _nQtdLib > 0
	
	Begin Transaction
	
	DbSelectArea("SC9")
	_cPedAnt  := SC9->C9_PEDIDO
	_cIteAnt  := SC9->C9_ITEM
	While SC9->(! Eof()) .AND. SC9->C9_FILIAL == xFilial("SC9") .AND. SC9->C9_PEDIDO == _cPedAnt .AND. SC9->C9_ITEM == _cIteAnt
		If SC9->C9_QTDLIB <= _nQtdLib
			If SC9->C9_SEQUEN == cSeqSC9
				_nLiberar += SC9->C9_QTDLIB
				RecLock('SC9',.F.)
				SC9->C9_BLINF   := Upper(Rtrim(CUSERNAME))+" "+dtoc(date())+" "+time()+" h"
				MsUnLock()
				AaDd(_aBlqReg,{SC9->(C9_PEDIDO+C9_ITEM+C9_SEQUEN),SC9->C9_BLPRE})
				A460Estorna()
			ElseIf Empty(SC9->C9_BLEST)
				_nLiberar += SC9->C9_QTDLIB
				RecLock('SC9',.F.)
				SC9->C9_BLINF   := Upper(Rtrim(CUSERNAME))+" "+dtoc(date())+" "+time()+" h"
				MsUnLock()
				AaDd(_aBlqReg,{SC9->(C9_PEDIDO+C9_ITEM+C9_SEQUEN),SC9->C9_BLPRE})
				A460Estorna()
			ElseIf !Empty(SC9->C9_BLEST) .AND. SC9->C9_BLEST <> '10'
				_nQtdPen += SC9->C9_QTDLIB
				RecLock('SC9',.F.)
				SC9->C9_BLINF   := Upper(Rtrim(CUSERNAME))+" "+dtoc(date())+" "+time()+" h"
				MsUnLock()
				AaDd(_aBlqReg,{SC9->(C9_PEDIDO+C9_ITEM+C9_SEQUEN),SC9->C9_BLPRE})
				A460Estorna()
			Endif
			// Em caso de liberacao parcial, entrara no if abaixo se o parametro mv_par08 estiver como Sim
			// Para analise verifique onde tem o parametro em todo programa
		ElseIf MV_PAR08 = 1 .And. SC9->C9_QTDLIB > _nQtdLib .And. SC9->C9_BLEST <> '10'
			If SC9->C9_SEQUEN == cSeqSC9
				_nLiberar += _nQtdLib
				_nQtdPen  += SC9->C9_QTDLIB-_nQtdLib
				RecLock('SC9',.F.)
				SC9->C9_BLINF   := Upper(Rtrim(CUSERNAME))+" "+dtoc(date())+" "+time()+" h"
				MsUnLock()
				AaDd(_aBlqReg,{SC9->(C9_PEDIDO+C9_ITEM+C9_SEQUEN),SC9->C9_BLPRE})
				A460Estorna()
			ElseIf Empty(SC9->C9_BLEST)
				_nLiberar += SC9->C9_QTDLIB
				RecLock('SC9',.F.)
				SC9->C9_BLINF   := Upper(Rtrim(CUSERNAME))+" "+dtoc(date())+" "+time()+" h"
				MsUnLock()
				AaDd(_aBlqReg,{SC9->(C9_PEDIDO+C9_ITEM+C9_SEQUEN),SC9->C9_BLPRE})
				A460Estorna()
			ElseIf !Empty(SC9->C9_BLEST) .AND. SC9->C9_BLEST <> '10'
				_nQtdPen += SC9->C9_QTDLIB
				RecLock('SC9',.F.)
				SC9->C9_BLINF   := Upper(Rtrim(CUSERNAME))+" "+dtoc(date())+" "+time()+" h"
				MsUnLock()
				AaDd(_aBlqReg,{SC9->(C9_PEDIDO+C9_ITEM+C9_SEQUEN),SC9->C9_BLPRE})
				A460Estorna()
			Endif
			// Fim
		ElseIf SC9->C9_BLEST <> '10'
			If Empty(SC9->C9_BLEST)
				_nLiberar += SC9->C9_QTDLIB
			ElseIf !Empty(SC9->C9_BLEST)
				_nQtdPen += SC9->C9_QTDLIB
			Endif
			RecLock('SC9',.F.)
			SC9->C9_BLINF   := Upper(Rtrim(CUSERNAME))+" "+dtoc(date())+" "+time()+" h"
			MsUnLock()
			AaDd(_aBlqReg,{SC9->(C9_PEDIDO+C9_ITEM+C9_SEQUEN),SC9->C9_BLPRE})
			A460Estorna()
		Endif
		SC9->(DbSkip())
	End
	
	If _nLiberar > 0
		MaLibDoFat(SC6->(Recno()),_nLiberar,IIf(cCredito<>Nil.And.!Empty(cCredito),.F.,.T.),.T.,.F.,.T.,.T.,.F.) //,{SC6->C6_LOCAL})
		_lLiber := .T.
	EndIf
	
	If _nQtdPen > 0
		MaLibDoFat(SC6->(Recno()),_nQtdPen,IIf(cCredito<>Nil.And.!Empty(cCredito),.F.,.T.),.F.,.F.,.F.,.F.,.F.) //,{SC6->C6_LOCAL})
	Endif
	
	SB2->(MsUnLock())
	
	End Transaction
	DbCommitAll()
	
	If _nLiberar > 0
		dbselectarea("SC6")
		Reclock("SC6",.f.)
		SC6->C6_IMPRE  := "   "
		msunlock()
	Endif
	DbSelectArea("SC9")
	
Endif

If _lLiber
	DbSelectArea("SC9")
	If SC9->(DbSeek(xFilial('SC9')+SC6->C6_NUM+SC6->C6_ITEM))
		_nRecSC9 := SC9->(Recno())
		While SC9->(! Eof()) .AND. SC9->C9_FILIAL == xFilial('SC9') .AND. SC9->C9_PEDIDO == SC6->C6_NUM .AND. SC9->C9_ITEM == SC6->C6_ITEM
			If Empty(SC9->C9_BLEST) .And. SC9->C9_DATALIB == dDatabase
				RecLock("SC9",.F.)
				SC9->C9_NFENT     := 'TESTA7'
				SC9->C9_SERENT    := 'SB2'
				_nAchaBlq := AsCan(_aBlqReg,{|x|x[1]==SC9->(C9_PEDIDO+C9_ITEM+C9_SEQUEN)})
				If _nAchaBlq > 0 .And. Empty(_aBlqReg[_nAchaBlq,2])
					SC9->C9_BLPRE     := ""
				ElseIf _nAchaBlq > 0 .And. !Empty(_aBlqReg[_nAchaBlq,2])
					SC9->C9_BLPRE     := _aBlqReg[_nAchaBlq,2]
				Endif
				SC9->C9_BLINF     := STR0040 //"LIB AUTOMATICA PED PENDENTE"
				MsUnLock()
			Endif
			DbSkip()
		End  
		DbGoTo(_nRecSC9)
	Endif
Endif

Return(_lLiber)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSplit     บ Autor ณ Ewerton C Tomaz    บ Data ณ  09/11/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5 IDE                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Template Function Split(xLine /*Linha*/, xSep /*Separador*/)		

Local aLine := {}

xLine += xSep
While At(xSep, xLine) > 0
	Aadd(aLine,Left(xLine,At(xSep, xLine)-1))  
	xLine := Subst(xLine,At(xSep, xLine)+len(xSep))  
End
Return aLine

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSplit     บ Autor ณ Ewerton C Tomaz    บ Data ณ  09/11/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5 IDE                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/       

Template Function Prazo(xLine /*Linha*/, xSep /*Separador*/)

Local aLine := {}

xLine += xSep
While At(xSep, xLine) > 0
	Aadd(aLine,Left(xLine,At(xSep, xLine)-1))
	xLine := Subst(xLine,At(xSep, xLine)+len(xSep))
End
Return aLine